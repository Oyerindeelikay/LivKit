import json
import stripe
from django.conf import settings
from django.http import HttpResponse
from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status

from .models import Entitlement, PaymentLog
from accounts.permissions import IsAuthenticatedAndNotBanned

from django.views.decorators.csrf import csrf_exempt
from django.utils.decorators import method_decorator

# ---------- STRIPE ---------- #

stripe.api_key = settings.STRIPE_SECRET_KEY


class StripeCreateCheckoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user

        # Ensure Stripe customer exists
        if not user.stripe_customer_id:
            customer = stripe.Customer.create(
                email=user.email,
                metadata={"user_id": user.id},
            )
            user.stripe_customer_id = customer.id
            user.save(update_fields=["stripe_customer_id"])

        try:
            session = stripe.checkout.Session.create(
                mode="payment",
                customer=user.stripe_customer_id,
                payment_method_types=["card"],
                success_url=settings.FRONTEND_SUCCESS_URL,
                cancel_url=settings.FRONTEND_CANCEL_URL,
                line_items=[
                    {
                        "price": settings.STRIPE_PRICE_ID,
                        "quantity": 1,
                    }
                ],
                metadata={
                    "user_id": str(user.id),
                    "price_id": settings.STRIPE_PRICE_ID,
                },
            )
        except stripe.error.StripeError:
            return Response(
                {"detail": "Unable to create checkout session"},
                status=status.HTTP_502_BAD_GATEWAY,
            )

        return Response({"checkout_url": session.url}, status=200)


# ---------- STRIPE WEBHOOK ---------- #



@csrf_exempt
def stripe_webhook(request):
    payload = request.body
    sig_header = request.META.get("HTTP_STRIPE_SIGNATURE")

    try:
        event = stripe.Webhook.construct_event(
            payload,
            sig_header,
            settings.STRIPE_WEBHOOK_SECRET,
        )
    except (ValueError, stripe.error.SignatureVerificationError):
        return HttpResponse(status=400)

    # Idempotency guard
    if StripeEvent.objects.filter(event_id=event.id).exists():
        return HttpResponse(status=200)

    if event["type"] == "checkout.session.completed":
        session = event["data"]["object"]

        # Defensive validation
        if session["payment_status"] != "paid":
            return HttpResponse(status=200)

        if session["metadata"].get("price_id") != settings.STRIPE_PRICE_ID:
            return HttpResponse(status=400)

        user_id = session["metadata"].get("user_id")
        payment_intent = session.get("payment_intent")

        User = get_user_model()
        try:
            user = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return HttpResponse(status=400)

        with transaction.atomic():
            StripeEvent.objects.create(event_id=event.id)

            entitlement, _ = Entitlement.objects.get_or_create(user=user)
            entitlement.activate(
                provider="stripe",
                reference=payment_intent,
            )

            PaymentLog.objects.create(
                user=user,
                provider="stripe",
                event=event["type"],
                reference=payment_intent,
                payload=session,
            )

    return HttpResponse(status=200)


# ---------- GOOGLE PLAY VERIFY ---------- #

from google.oauth2 import service_account
from googleapiclient.discovery import build


class GoogleVerifyPurchaseView(APIView):
    permission_classes = [IsAuthenticated, IsAuthenticatedAndNotBanned]

    def post(self, request):
        user = request.user

        entitlement, _ = Entitlement.objects.get_or_create(user=user)
        if entitlement.is_active:
            return Response({
                "already_paid": True,
                "message": "You’ve already unlocked premium content!"
            }, status=200)



        purchase_token = request.data.get("purchaseToken")
        product_id = request.data.get("productId")
        package_name = request.data.get("packageName")

        if not (purchase_token and product_id and package_name):
            return Response({"error": "Missing fields"}, status=400)

        credentials = service_account.Credentials.from_service_account_file(
            settings.GOOGLE_SERVICE_ACCOUNT_FILE,
            scopes=["https://www.googleapis.com/auth/androidpublisher"],
        )

        service = build("androidpublisher", "v3", credentials=credentials)
        result = service.purchases().products().get(
            packageName=package_name,
            productId=product_id,
            token=purchase_token
        ).execute()

        # Google's response
        purchase_state = result.get("purchaseState")   # 0 = Purchased
        order_id = result.get("orderId")

        if purchase_state != 0:
            return Response({"error": "Purchase not valid"}, status=400)

        entitlement.activate("playstore", order_id)

        PaymentLog.objects.create(
            user=user,
            provider="playstore",
            event="purchase.verified",
            reference=order_id,
            payload=result
        )

        return Response({"detail": "Access granted"})
