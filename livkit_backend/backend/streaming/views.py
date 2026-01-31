import random
from django.utils import timezone
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from rest_framework import status
from decimal import Decimal
from agora_token_builder import RtcTokenBuilder

from .models import LiveStream, LiveViewSession
from .serializers import LiveStreamSerializer
from .agora import generate_agora_token

MIN_PAYABLE_MINUTES = 2



HEARTBEAT_INTERVAL = 30  # seconds
HEARTBEAT_TIMEOUT = 60   # seconds


AGORA_ROLE_PUBLISHER = 1
AGORA_ROLE_SUBSCRIBER = 2


class CreateLiveStreamView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        print("[DEBUG] Create stream requested by:", user.id)

        channel_name = f"live_{user.id}_{int(timezone.now().timestamp())}"

        stream = LiveStream.objects.create(
            streamer=user,
            channel_name=channel_name,
            is_live=True,
            started_at=timezone.now()
        )

        try:
            token = generate_agora_token(
                channel_name=channel_name,
                uid=0,
                role=AGORA_ROLE_PUBLISHER
            )
        except Exception as e:
            print("[AGORA ERROR]", str(e))
            stream.delete()
            return Response(
                {"detail": "Agora token error"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        try:
            stream_data = LiveStreamSerializer(stream).data
        except Exception as e:
            print("[SERIALIZER ERROR]", e)
            raise

        return Response(
            {
                "stream": stream_data,
                "agora_token": token,
                "channel_name": channel_name,
            },
            status=status.HTTP_201_CREATED
        )






class LeaveLiveStreamView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, stream_id):
        user = request.user

        try:
            session = LiveViewSession.objects.get(
                stream_id=stream_id,
                viewer=user,
                is_active=True
            )
        except LiveViewSession.DoesNotExist:
            return Response(
                {"detail": "Session not found"},
                status=status.HTTP_400_BAD_REQUEST
            )

        session.force_end(reason="viewer_left")

        minutes = session.active_seconds // 60
        session.minutes_watched = minutes

        if minutes < MIN_PAYABLE_MINUTES:
            session.save(update_fields=["minutes_watched"])
            return Response(
                {"detail": "Left stream (no payout)"},
                status=status.HTTP_200_OK
            )

        pay_per_minute = Decimal("0.10")
        earnings = Decimal(minutes) * pay_per_minute

        session.earnings_generated = earnings
        session.save(update_fields=[
            "minutes_watched",
            "earnings_generated"
        ])

        stream = session.stream
        stream.total_earnings = (stream.total_earnings or 0) + earnings

        stream.save(update_fields=["total_earnings"])

        return Response(
            {
                "detail": "Left stream successfully",
                "minutes": minutes,
                "earnings": earnings,
            },
            status=status.HTTP_200_OK
        )



class StreamHeartbeatView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, stream_id):
        user = request.user

        try:
            session = LiveViewSession.objects.get(
                stream_id=stream_id,
                viewer=user,
                is_active=True,
                left_at__isnull=True
            )
        except LiveViewSession.DoesNotExist:
            return Response(
                {"detail": "No active session"},
                status=status.HTTP_400_BAD_REQUEST
            )

        now = timezone.now()
        delta = (now - session.last_heartbeat).total_seconds()

        if delta > HEARTBEAT_TIMEOUT:
            session.force_end(reason="heartbeat_timeout")
            return Response(
                {"detail": "Session expired"},
                status=status.HTTP_410_GONE
            )

        session.active_seconds += HEARTBEAT_INTERVAL
        session.last_heartbeat = now
        session.save(update_fields=["active_seconds", "last_heartbeat"])

        return Response(
            {
                "status": "ok",
                "active_seconds": session.active_seconds,
            },
            status=status.HTTP_200_OK
        )


class EndLiveStreamView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, stream_id):
        user = request.user

        try:
            stream = LiveStream.objects.get(
                id=stream_id,
                streamer=user,
                is_live=True
            )
        except LiveStream.DoesNotExist:
            return Response(
                {"detail": "Stream not found or already ended"},
                status=status.HTTP_404_NOT_FOUND
            )

        # End stream
        stream.is_live = False
        stream.ended_at = timezone.now()
        stream.save(update_fields=["is_live", "ended_at"])

        # Force end all active viewer sessions
        active_sessions = LiveViewSession.objects.filter(
            stream=stream,
            is_active=True
        )

        for session in active_sessions:
            session.force_end(reason="stream_ended")

            minutes = session.active_seconds // 60
            session.minutes_watched = minutes

            if minutes >= MIN_PAYABLE_MINUTES:
                pay_per_minute = random.uniform(0.05, 0.20)
                earnings = minutes * pay_per_minute

                session.earnings_generated = earnings
                stream.total_earnings = (stream.total_earnings or 0) + earnings


            session.save()

        stream.save(update_fields=["total_earnings"])

        print(
            f"[DEBUG] Stream {stream.id} ended by streamer {user}"
        )

        return Response(
            {
                "detail": "Live stream ended",
                "total_earnings": stream.total_earnings,
                "total_views": stream.total_views,
            },
            status=status.HTTP_200_OK
        )


class JoinLiveStreamView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request, stream_id):
        user = request.user

        try:
            stream = LiveStream.objects.get(id=stream_id, is_live=True)
        except LiveStream.DoesNotExist:
            return Response(
                {"detail": "Stream not available"},
                status=status.HTTP_404_NOT_FOUND
            )

        if stream.streamer == user:
            return Response(
                {"detail": "Streamer cannot join own stream"},
                status=status.HTTP_400_BAD_REQUEST
            )

        LiveViewSession.objects.filter(
            stream=stream,
            viewer=user,
            is_active=True
        ).delete()

        session = LiveViewSession.objects.create(
            stream=stream,
            viewer=user
        )

        stream.total_views += 1
        stream.save(update_fields=["total_views"])

        try:
            token = generate_agora_token(
                channel_name=stream.channel_name,
                uid=user.id,
                role=AGORA_ROLE_SUBSCRIBER
            )
        except Exception as e:
            print("[AGORA ERROR]", str(e))
            return Response(
                {"detail": "Token generation failed"},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )

        return Response(
            {
                "stream_id": str(stream.id),
                "channel_name": stream.channel_name,
                "agora_token": token,
                "heartbeat_interval": HEARTBEAT_INTERVAL,
            },
            status=status.HTTP_200_OK
        )


class ActiveLiveStreamView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        active_streams = LiveStream.objects.filter(is_live=True).order_by("-started_at")
        serializer = LiveStreamSerializer(active_streams, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
