from rest_framework.views import APIView
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from django.shortcuts import get_object_or_404
from .services import calculate_session_earnings
from django.db import transaction

from rest_framework.decorators import permission_classes
from rest_framework.permissions import AllowAny
from .hms import generate_hms_token
from .serializers import ScheduleLiveSerializer

from django.utils import timezone
from .serializers import ViewerJoinSerializer



from .services import calculate_session_earnings

from .models import LiveSession, ViewerSessionEvent, LiveRoom
from .hms import verify_hms_signature
from accounts.models import User  # adjust if needed




class HMSWebhookView(APIView):

    permission_classes = [AllowAny]  # HMS server, not users

    @transaction.atomic
    def handle_room_ended(self, session):
        session.status = "ended"
        session.actual_end = timezone.now()
        session.save(update_fields=["status", "actual_end"])

        # Force close all open viewer events
        ViewerSessionEvent.objects.filter(
            session=session,
            left_at__isnull=True
        ).update(left_at=session.actual_end)

        # Now compute earnings
        calculate_session_earnings(session)



    def post(self, request):
        # 1. Verify HMS
        if not verify_hms_signature(request):
            return Response({"detail": "Invalid signature"}, status=403)

        data = request.data



        event = data.get("type")
        room_id = data.get("data", {}).get("room_id")

        # Handle room lifecycle FIRST
        if event == "room.started":
            session = (
                LiveSession.objects
                .filter(room__hms_room_id=room_id, status="scheduled")
                .order_by("-created_at")
                .first()
            )
            if session:
                session.status = "live"
                session.actual_start = timezone.now()
                session.save(update_fields=["status", "actual_start"])
            return Response({"detail": "room started handled"}, status=200)


        if event == "room.ended":
            session = (
                LiveSession.objects
                .filter(room__hms_room_id=room_id, status="live")
                .first()
            )
            if session:
                self.handle_room_ended(session)
            return Response({"detail": "room ended handled"}, status=200)




        peer = data.get("data", {}).get("peer", {})

        user_id = peer.get("user_id")
        role = peer.get("role")

        # We do NOT care about host events for earnings
        if role != "viewer":
            return Response({"detail": "ignored"}, status=200)

        # Find active live session for this room
        session = (
            LiveSession.objects
            .filter(room__hms_room_id=room_id, status="live")
            .first()
        )

        if not session:
            return Response({"detail": "No active session"}, status=200)

        try:
            viewer = User.objects.get(id=user_id)
        except User.DoesNotExist:
            return Response({"detail": "User not found"}, status=200)

        # Idempotent handling
        if event == "peer.joined":
            self.handle_peer_joined(session, viewer)

        elif event == "peer.left":
            self.handle_peer_left(session, viewer)

        return Response({"status": "ok"}, status=200)

    @transaction.atomic
    def handle_peer_joined(self, session, viewer):
        """
        Create a new join event ONLY if there is no open one
        """
        open_event = ViewerSessionEvent.objects.filter(
            session=session,
            viewer=viewer,
            left_at__isnull=True,
        ).exists()

        if open_event:
            return

        ViewerSessionEvent.objects.create(
            session=session,
            viewer=viewer,
            joined_at=timezone.now(),
        )

    @transaction.atomic
    def handle_peer_left(self, session, viewer):
        """
        Close the latest open event
        """
        event = (
            ViewerSessionEvent.objects
            .filter(
                session=session,
                viewer=viewer,
                left_at__isnull=True,
            )
            .order_by("-joined_at")
            .first()
        )

        if not event:
            return

        event.left_at = timezone.now()
        event.save(update_fields=["left_at"])

class ScheduleLiveView(APIView):
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        serializer = ScheduleLiveSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        room_id = serializer.validated_data["room_id"]
        scheduled_start = serializer.validated_data["scheduled_start"]

        if scheduled_start <= timezone.now():
            return Response(
                {"detail": "Scheduled time must be in the future"},
                status=400,
            )

        room = get_object_or_404(
            LiveRoom,
            id=room_id,
            host=request.user,
        )

        existing = LiveSession.objects.filter(
            host=request.user,
            status="scheduled",
            scheduled_start__gte=timezone.now(),
        ).exists()

        if existing:
            return Response(
                {"detail": "You already have a scheduled live"},
                status=400,
            )

        session = LiveSession.objects.create(
            host=request.user,
            room=room,
            scheduled_start=scheduled_start,
            status="scheduled",
        )

        return Response(
            {
                "session_id": session.id,
                "room_id": room.id,
                "scheduled_start": session.scheduled_start,
                "status": session.status,
            },
            status=201,
        )



class GoLiveView(APIView):
    permission_classes = [IsAuthenticated]

    @transaction.atomic
    def post(self, request):
        session_id = request.data.get("session_id")

        # 1️⃣ If there's already a live session, reuse it
        session = LiveSession.objects.select_for_update().filter(
            host=request.user,
            status="live"
        ).first()

        if not session and session_id:
            session = LiveSession.objects.select_for_update().filter(
                id=session_id,
                host=request.user
            ).first()

            if session and session.status in ["ended", "cancelled"]:
                session = None

        # 2️⃣ Create new session only if none exists
        if not session:
            room = LiveRoom.objects.filter(host=request.user).first()
            if not room:
                room = LiveRoom.objects.create(
                    host=request.user,
                    title="Untitled Room",
                    hms_room_id=f"room-{request.user.id}-{int(timezone.now().timestamp())}",
                    hms_room_name=f"{request.user.username}-room",
                )

            session = LiveSession.objects.create(
                host=request.user,
                room=room,
                status="scheduled",
                scheduled_start=timezone.now(),
            )

        # 3️⃣ Promote to live only if needed
        if session.status != "live":
            session.go_live()

        # 4️⃣ ALWAYS return 200 with valid token
        token = generate_hms_token(
            user_id=request.user.id,
            room_id=session.room.hms_room_id,
            role="host",
        )

        return Response(
            {
                "token": token,
                "room_id": session.room.hms_room_id,
                "session_id": session.id,
                "status": session.status,
            },
            status=200,
        )




class EndLiveView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        print("EndLiveView called")  # debug comment

        session_id = request.data.get("session_id")

        if not session_id:
            return Response(
                {"detail": "session_id is required"},
                status=400,
            )

        session = get_object_or_404(
            LiveSession,
            id=session_id,
            host=request.user,
            status="live",
        )

        session.actual_end = timezone.now()
        session.status = "ended"
        session.save(update_fields=["actual_end", "status"])

        print("Live session ended:", session.id)  # debug comment

        ViewerSessionEvent.objects.filter(
            session=session,
            left_at__isnull=True
        ).update(left_at=session.actual_end)

        earnings = calculate_session_earnings(session)

        return Response(
            {
                "session_id": session.id,
                "status": session.status,
                "total_earned": str(earnings),
            }
        )


class ViewerJoinLiveView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = ViewerJoinSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        session_id = serializer.validated_data["session_id"]

        session = get_object_or_404(LiveSession, id=session_id)

        # 🔒 CRITICAL CHECKS
        if session.status != "live":
            return Response(
                {"detail": "Live session is not active"},
                status=400,
            )

        # Generate viewer token
        token = generate_hms_token(
            user_id=request.user.id,
            room_id=session.room.hms_room_id,
            role="viewer",
        )

        return Response({
            "token": token,
            "room_id": session.room.hms_room_id,
            "session_id": session.id,
        })
