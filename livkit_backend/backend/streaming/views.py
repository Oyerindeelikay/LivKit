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


from django.db import IntegrityError
from django.db.utils import DataError
import traceback

class CreateLiveStreamView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        print("[DEBUG] STEP 1: request entered, user =", user.id)

        try:
            channel_name = f"live_{user.id}_{int(timezone.now().timestamp())}"
            print("[DEBUG] STEP 2: channel_name =", channel_name)

            stream = LiveStream.objects.create(
                streamer=user,
                channel_name=channel_name,
                is_live=True,
                started_at=timezone.now()
            )
            print("[DEBUG] STEP 3: stream created, id =", stream.id)

        except IntegrityError as e:
            print("[DB ERROR] IntegrityError:", e)
            traceback.print_exc()
            return Response({"detail": "DB integrity error"}, status=500)

        except DataError as e:
            print("[DB ERROR] DataError:", e)
            traceback.print_exc()
            return Response({"detail": "DB data error"}, status=500)

        except Exception as e:
            print("[UNKNOWN ERROR] during stream create:", e)
            traceback.print_exc()
            return Response({"detail": "Unknown create error"}, status=500)

        try:
            print("[DEBUG] STEP 4: generating Agora token")
            token = generate_agora_token(
                channel_name=channel_name,
                uid=0,
                role=AGORA_ROLE_PUBLISHER
            )
            print("[DEBUG] STEP 5: Agora token OK")

        except Exception as e:
            print("[AGORA ERROR]", e)
            traceback.print_exc()
            stream.delete()
            return Response({"detail": "Agora token error"}, status=500)

        try:
            print("[DEBUG] STEP 6: serializing stream")
            stream_data = LiveStreamSerializer(stream).data
            print("[DEBUG] STEP 7: serialization OK")

        except Exception as e:
            print("[SERIALIZER ERROR]", e)
            traceback.print_exc()
            return Response({"detail": "Serialization error"}, status=500)

        print("[DEBUG] STEP 8: returning response")

        return Response(
            {
                "stream": stream_data,
                "agora_token": token,
                "channel_name": channel_name,
            },
            status=201
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

        pay_per_minute = Decimal(str(random.uniform(0.05, 0.20)))
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
                pay_per_minute = Decimal(str(random.uniform(0.05, 0.20)))
                earnings = Decimal(minutes) * pay_per_minute

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
        print("[DEBUG] ACTIVE: fetching streams")

        try:
            qs = LiveStream.objects.filter(is_live=True)
            print("[DEBUG] ACTIVE: queryset OK, count =", qs.count())

            data = LiveStreamSerializer(qs, many=True).data
            print("[DEBUG] ACTIVE: serialization OK")

            return Response(data, status=200)

        except Exception as e:
            print("[ACTIVE ERROR]", e)
            import traceback
            traceback.print_exc()
            return Response({"detail": "Active stream error"}, status=500)
