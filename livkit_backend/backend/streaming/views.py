from django.utils.timezone import now
from django.shortcuts import get_object_or_404
from rest_framework.decorators import api_view, permission_classes
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework import status
from .models import LiveStream, ViewerSession, MinuteBalance, Gift
from .serializers import LiveStreamSerializer, MinuteBalanceSerializer
import uuid
from django.http import HttpResponse

from django.views.decorators.csrf import csrf_exempt
from rest_framework.views import APIView
import stripe
from django.conf import settings
from .agora_utils import generate_agora_token
import json
import traceback
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
         
# -------------------------------
# START STREAM (HOST)
# -------------------------------
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def start_stream(request, stream_id):
    stream = get_object_or_404(
        LiveStream,
        id=stream_id,
        host=request.user,
    )

    print(
        f"[START_STREAM] host={request.user.id}, "
        f"stream={stream.id}, status_before={stream.status}"
    )

    if stream.status == "live":
        print("[START_STREAM] ❌ Stream already live")
        return Response({"error": "Stream is already live"}, status=400)

    # Mark stream live
    stream.status = "live"
    stream.started_at = now()
    stream.ended_at = None
    stream.save(update_fields=["status", "started_at", "ended_at"])

    print(
        f"[START_STREAM] ✅ Stream marked live | "
        f"channel={stream.agora_channel}"
    )

    # IMPORTANT: UID = 0 (Agora auto-assign)
    agora_token = generate_agora_token(
        channel_name=stream.agora_channel,
        uid=0,
        is_host=True,
    )

    print("[START_STREAM] 🎟️ Agora host token generated")

    return Response({
        "stream_id": str(stream.id),
        "agora_channel": stream.agora_channel,
        "agora_token": agora_token,
        "uid": 0,
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


# -------------------------------
# JOIN STREAM (VIEWER)
# -------------------------------
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def join_stream(request, stream_id):
    stream = get_object_or_404(LiveStream, id=stream_id)

    print(
        f"[JOIN_STREAM] user={request.user.id}, "
        f"stream={stream.id}, status={stream.status}"
    )

    if stream.status != "live":
        print("[JOIN_STREAM] ❌ Stream not live")
        return Response(
            {"error": "This stream is not currently live"},
            status=400
        )

    # Ensure viewer has minutes
    balance, _ = MinuteBalance.objects.get_or_create(user=request.user)

    print(
        f"[JOIN_STREAM] viewer={request.user.id}, "
        f"seconds_balance={balance.seconds_balance}"
    )

    if balance.seconds_balance <= 0:
        print("[JOIN_STREAM] ❌ Insufficient minutes")
        return Response({"error": "Insufficient minutes"}, status=403)

    # Track viewer session
    ViewerSession.objects.update_or_create(
        user=request.user,
        stream=stream,
        defaults={"is_active": True}
    )

    print("[JOIN_STREAM] 👀 Viewer session active")

    # UID = 0 (Agora auto-assign)
    agora_token = generate_agora_token(
        channel_name=stream.agora_channel,
        uid=0,
        is_host=False,
    )

    print("[JOIN_STREAM] 🎟️ Agora viewer token generated")

    return Response({
        "stream_id": str(stream.id),
        "agora_channel": stream.agora_channel,
        "agora_token": agora_token,
        "uid": 0,
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

# -------------------------------
# LIST ACTIVE / RECENT STREAMS
# -------------------------------
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def list_streams(request):
    recent_cutoff = now() - timedelta(minutes=30)

    streams = LiveStream.objects.filter(
        status__in=["live", "ended"],
        ended_at__gte=recent_cutoff
    ).order_by("-started_at")

    print(
        f"[LIST_STREAMS] user={request.user.id}, "
        f"count={streams.count()}"
    )

    return Response(
        LiveStreamSerializer(streams, many=True).data
    )

# -------------------------------
# GET REMAINING MINUTES
# -------------------------------
@api_view(["GET"])
@permission_classes([IsAuthenticated])
def minutes_balance(request):
    balance, _ = MinuteBalance.objects.get_or_create(user=request.user)

    print(
        f"[MINUTES_BALANCE] user={request.user.id}, "
        f"seconds={balance.seconds_balance}"
    )

    return Response(
        MinuteBalanceSerializer(balance).data
    )


# -------------------------------
# GET VIEWER TOKEN (REJOIN)
# -------------------------------
@api_view(["POST"])
@permission_classes([IsAuthenticated])
def get_viewer_token(request, stream_id):
    stream = get_object_or_404(LiveStream, id=stream_id)

    print(
        f"[GET_VIEWER_TOKEN] user={request.user.id}, "
        f"stream={stream.id}, status={stream.status}"
    )

    if stream.status != "live":
        print("[GET_VIEWER_TOKEN] ❌ Stream not live")
        return Response({"error": "Stream is not live"}, status=400)

    agora_token = generate_agora_token(
        channel_name=stream.agora_channel,
        uid=0,
        is_host=False,
    )

    print("[GET_VIEWER_TOKEN] 🎟️ Viewer token generated")

    return Response({
        "stream_id": str(stream.id),
        "agora_channel": stream.agora_channel,
        "agora_token": agora_token,
        "uid": 0,
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
    try:
        print("\n\n==== STRIPE WEBHOOK HIT ====")

        payload = request.body
        print("RAW BODY:", payload)

        sig_header = request.META.get("HTTP_STRIPE_SIGNATURE")
        print("SIG HEADER:", sig_header)

        endpoint_secret = settings.STRIPE_MINUTES_WEBHOOK_SECRET
        print("ENDPOINT SECRET EXISTS:", bool(endpoint_secret))

        event = stripe.Webhook.construct_event(
            payload, sig_header, endpoint_secret
        )

        print("EVENT TYPE:", event["type"])

        if event["type"] != "checkout.session.completed":
            print("Ignoring event")
            return HttpResponse(status=200)

        session = event["data"]["object"]
        print("SESSION:", json.dumps(session, indent=2))

        metadata = session.get("metadata", {})
        print("METADATA:", metadata)

        user_id = metadata.get("user_id")
        session_id = session.get("id")

        print("USER ID:", user_id)
        print("SESSION ID:", session_id)

        if PaymentLog.objects.filter(reference=session_id).exists():
            print("Already processed")
            return HttpResponse(status=200)

        user = User.objects.get(id=user_id)
        print("USER FOUND:", user)

        balance, _ = MinuteBalance.objects.get_or_create(user=user)
        print("BALANCE BEFORE:", balance.seconds_balance)

        balance.seconds_balance += settings.SECONDS_PER_MINUTE_PACKAGE
        balance.save()

        print("BALANCE AFTER:", balance.seconds_balance)

        PaymentLog.objects.create(
            user=user,
            provider="stripe",
            event="checkout.session.completed",
            reference=session_id,
            payload=session,
        )

        print("PAYMENT LOG CREATED")

        return HttpResponse(status=200)

    except Exception as e:
        print("\n\n🔥🔥🔥 WEBHOOK CRASHED 🔥🔥🔥")
        print("ERROR:", str(e))
        traceback.print_exc()
        return HttpResponse(status=500)
