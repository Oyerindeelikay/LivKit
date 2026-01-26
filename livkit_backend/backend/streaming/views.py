from django.utils.timezone import now
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import LiveStream, ViewerSession, MinuteBalance, Gift
from .serializers import LiveStreamSerializer, MinuteBalanceSerializer
import uuid
from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
import stripe
from django.conf import settings
from .agora_utils import generate_agora_token

from django.contrib.auth import get_user_model
from payments.models import PaymentLog 
from .models import StreamEarning
from .serializers import StreamEarningSerializer
from datetime import timedelta


stripe.api_key = settings.STRIPE_SECRET_KEY
User = get_user_model()



streams = LiveStream.objects.filter(status="live") | \
           LiveStream.objects.filter(
               status="ended",
               ended_at__gte=now() - timedelta(minutes=10)
           )
           
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def start_stream(request, stream_id):
    stream = get_object_or_404(LiveStream, id=stream_id, host=request.user)

    if stream.status == "live":
        return Response({"error": "Stream is already live"}, status=400)

    stream.status = "live"
    stream.started_at = now()
    stream.save()

    # Generate Agora token for HOST (broadcaster)
    host_uid = request.user.id  # use Django user ID as Agora UID

    agora_token = generate_agora_token(
        channel_name=stream.agora_channel,
        uid=host_uid,
        is_host=True,
    )

    return Response({
        "stream_id": str(stream.id),
        "agora_channel": stream.agora_channel,
        "agora_token": agora_token,
        "uid": host_uid,
        "role": "host",
    })




# --- CREATE / SCHEDULE STREAM ---
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def create_stream(request):
    title = request.data.get("title")
    scheduled_at = request.data.get("scheduled_at")

    stream = LiveStream.objects.create(
        host=request.user,
        title=title,
        scheduled_at=scheduled_at,
        agora_channel=str(uuid.uuid4()),
    )

    return Response(LiveStreamSerializer(stream).data, status=201)



@api_view(["POST"])
@permission_classes([IsAuthenticated])
def join_stream(request, stream_id):

    stream = get_object_or_404(LiveStream, id=stream_id)
    if stream.status != "live":
        return Response(
            {"error": "This stream is not currently live"},
            status=400
        )


    balance, _ = MinuteBalance.objects.get_or_create(user=request.user)

    if balance.seconds_balance <= 0:
        return Response({"error": "Insufficient minutes"}, status=403)

    ViewerSession.objects.update_or_create(
        user=request.user,
        stream=stream,
        defaults={"is_active": True}
    )

    viewer_uid = request.user.id

    agora_token = generate_agora_token(
        channel_name=stream.agora_channel,
        uid=viewer_uid,
        is_host=False,
    )

    return Response({
        "stream_id": str(stream.id),
        "agora_channel": stream.agora_channel,
        "agora_token": agora_token,
        "uid": viewer_uid,
        "role": "audience",
    })




# --- END STREAM ---
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def end_stream(request, stream_id):
    stream = get_object_or_404(LiveStream, id=stream_id, host=request.user)

    stream.status = "ended"
    stream.ended_at = now()
    stream.save()

    return Response({"message": "Stream ended"})


# --- LIST ACTIVE STREAMS ---
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def list_streams(request):
    recent_cutoff = now() - timedelta(minutes=30)  # last 30 minutes
    streams = LiveStream.objects.filter(
        status__in=["live", "ended"],
        ended_at__gte=recent_cutoff
    )
    return Response(LiveStreamSerializer(streams, many=True).data)


# --- GET REMAINING MINUTES ---
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def minutes_balance(request):
    balance, _ = MinuteBalance.objects.get_or_create(user=request.user)
    return Response(MinuteBalanceSerializer(balance).data)

@api_view(["POST"])
@permission_classes([IsAuthenticated])
def get_viewer_token(request, stream_id):
    stream = get_object_or_404(LiveStream, id=stream_id)

    # Ensure stream is live
    if stream.status != "live":
        return Response({"error": "Stream is not live"}, status=400)

    viewer_uid = request.user.id

    agora_token = generate_agora_token(
        channel_name=stream.agora_channel,
        uid=viewer_uid,
        is_host=False,
    )

    return Response({
        "stream_id": str(stream.id),
        "agora_channel": stream.agora_channel,
        "agora_token": agora_token,
        "uid": viewer_uid,
        "role": "audience",
    })



@api_view(["GET"])
@permission_classes([IsAuthenticated])
def stream_earnings(request, stream_id):
    stream = get_object_or_404(LiveStream, id=stream_id)

    # Only host can view their earnings
    if stream.host != request.user:
        return Response({"error": "Not authorized"}, status=403)

    earning, _ = StreamEarning.objects.get_or_create(
        stream=stream,
        host=request.user,
    )

    return Response(StreamEarningSerializer(earning).data)




class StripeMinutesCheckoutView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user

        session = stripe.checkout.Session.create(
            mode="payment",
            success_url=settings.FRONTEND_SUCCESS_URL,
            cancel_url=settings.FRONTEND_CANCEL_URL,
            customer_email=user.email,
            line_items=[
                {
                    "price": settings.STRIPE_MINUTES_PRICE_ID,
                    "quantity": 1,
                }
            ],
            metadata={
                "user_id": user.id,
                "purchase_type": "minutes"
            }
        )

        return Response({"checkout_url": session.url})


@csrf_exempt
def stripe_minutes_webhook(request):
    print(">>>>>>> MINUTES WEBHOOK HIT")

    try:
        payload = request.body
        sig_header = request.META.get("HTTP_STRIPE_SIGNATURE")

        event = stripe.Webhook.construct_event(
            payload,
            sig_header,
            settings.STRIPE_MINUTES_WEBHOOK_SECRET
        )

        if event["type"] != "checkout.session.completed":
            return HttpResponse(status=200)

        session = event["data"]["object"]
        print("SESSION DATA:", session)

        metadata = session.get("metadata", {})
        if metadata.get("purchase_type") != "minutes":
            return HttpResponse(status=200)

        user_id = metadata.get("user_id")
        transaction_id = session["id"]

        print("USER ID:", user_id)
        print("TX ID:", transaction_id)

        if not user_id:
            return HttpResponse(status=200)

        User = get_user_model()
        user = User.objects.get(id=user_id)

        reference = f"minutes:{transaction_id}"

        if PaymentLog.objects.filter(reference=reference).exists():
            print("⚠️ Duplicate minutes transaction")
            return HttpResponse(status=200)

        wallet, _ = MinuteWallet.objects.get_or_create(user=user)
        wallet.seconds_balance += 600  # example
        wallet.save()

        PaymentLog.objects.create(
            user=user,
            provider="stripe",
            event="minutes",
            reference=reference,
            payload=session
        )

        return HttpResponse(status=200)

    except Exception as e:
        print("❌ MINUTES WEBHOOK CRASH:", repr(e))
        return HttpResponse(status=500)


