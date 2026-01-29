from django.conf import settings
from django.db import models
from django.utils import timezone
User = settings.AUTH_USER_MODEL

from rest_framework import serializers

class LiveRoom(models.Model):
    """
    Maps directly to a 100ms room
    """
    title = models.CharField(max_length=255)
    description = models.TextField(blank=True)

    hms_room_id = models.CharField(max_length=255, unique=True)
    hms_room_name = models.CharField(max_length=255)
    host = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
        related_name="live_rooms"
    )


    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"LiveRoom({self.title})"


class LiveSession(models.Model):
    """
    Represents ONE actual live stream event
    """
    STATUS_CHOICES = (
        ("scheduled", "Scheduled"),
        ("live", "Live"),
        ("ended", "Ended"),
        ("cancelled", "Cancelled"),
    )

    host = models.ForeignKey(
        User, on_delete=models.CASCADE, related_name="hosted_lives"
    )
    room = models.ForeignKey(
        LiveRoom, on_delete=models.CASCADE, related_name="sessions"
    )

    scheduled_start = models.DateTimeField(null=True, blank=True)
    actual_start = models.DateTimeField(null=True, blank=True)
    actual_end = models.DateTimeField(null=True, blank=True)

    status = models.CharField(
        max_length=20, choices=STATUS_CHOICES, default="scheduled"
    )

    total_earned = models.DecimalField(
        max_digits=10, decimal_places=2, default=0
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def go_live(self):
        self.status = "live"
        self.actual_start = timezone.now()
        self.save(update_fields=["status", "actual_start"])
        print("LiveSession is now LIVE")  # debug comment

    def end_live(self):
        self.status = "ended"
        self.actual_end = timezone.now()
        self.save(update_fields=["status", "actual_end"])
        print("LiveSession has ENDED")  # debug comment

    def __str__(self):
        return f"LiveSession(host={self.host}, status={self.status})"






class ScheduleLiveSerializer(serializers.Serializer):
    room_id = serializers.IntegerField()
    scheduled_start = serializers.DateTimeField()

    def validate_scheduled_start(self, value):
        """
        Prevent scheduling lives in the past
        """
        from django.utils import timezone

        if value <= timezone.now():
            print("Invalid scheduled_start: in the past")  # debug comment
            raise serializers.ValidationError(
                "Scheduled start must be in the future."
            )

        print("Scheduled start time validated")  # debug comment
        return value


class ViewerPingSerializer(serializers.Serializer):
    session_id = serializers.IntegerField()

    def validate_session_id(self, value):
        from .models import LiveSession

        if not LiveSession.objects.filter(id=value, status="live").exists():
            print("Invalid or inactive live session")  # debug comment
            raise serializers.ValidationError(
                "Live session does not exist or is not live."
            )

        print("ViewerPing session validated")  # debug comment
        return value



class ViewerSessionEvent(models.Model):
    session = models.ForeignKey(
        LiveSession,
        on_delete=models.CASCADE,
        related_name="viewer_events",
    )
    viewer = models.ForeignKey(
        settings.AUTH_USER_MODEL,
        on_delete=models.CASCADE,
    )

    joined_at = models.DateTimeField()
    left_at = models.DateTimeField(null=True, blank=True)

    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        indexes = [
            models.Index(fields=["session", "viewer"]),
        ]

    def __str__(self):
        return f"{self.viewer_id} in {self.session_id}"


