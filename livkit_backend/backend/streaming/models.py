import uuid
from django.conf import settings
from django.db import models
from django.utils import timezone
from decimal import Decimal


User = settings.AUTH_USER_MODEL


class LiveStream(models.Model):
    """
    Represents a single live session.
    One streamer, many viewers.
    """
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)

    streamer = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="live_streams"
    )

    channel_name = models.CharField(max_length=255, unique=True)

    is_live = models.BooleanField(default=False)

    started_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)

    total_views = models.PositiveIntegerField(default=0)

    total_earnings = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=Decimal("0.00")
    )

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.channel_name} ({self.streamer})"


class LiveViewSession(models.Model):
    stream = models.ForeignKey(
        LiveStream,
        on_delete=models.CASCADE,
        related_name="view_sessions"
    )

    viewer = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name="viewed_streams"
    )

    joined_at = models.DateTimeField(auto_now_add=True)
    left_at = models.DateTimeField(null=True, blank=True)

    last_heartbeat = models.DateTimeField(auto_now_add=True)

    active_seconds = models.PositiveIntegerField(default=0)

    minutes_watched = models.PositiveIntegerField(default=0)

    earnings_generated = models.DecimalField(
        max_digits=8,
        decimal_places=2,
        default=Decimal("0.00")
    )

    is_active = models.BooleanField(default=True)

    def __str__(self):
        return f"{self.viewer} on {self.stream}"

    def force_end(self, reason="unknown"):
        self.left_at = timezone.now()
        self.is_active = False

        self.minutes_watched = max(0, self.active_seconds // 60)

        print(
            f"[ANTI-FRAUD] Session force-ended "
            f"(viewer={self.viewer}, reason={reason})"
        )

        self.save()

