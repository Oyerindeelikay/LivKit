from django.conf import settings
from django.db import models
import uuid
from decimal import Decimal

User = settings.AUTH_USER_MODEL





class LiveStream(models.Model):
    STATUS_CHOICES = [
        ("scheduled", "Scheduled"),
        ("live", "Live"),
        ("ended", "Ended"),
    ]

    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    host = models.ForeignKey(User, on_delete=models.CASCADE, related_name="hosted_streams")
    title = models.CharField(max_length=255)
    scheduled_at = models.DateTimeField(null=True, blank=True)
    started_at = models.DateTimeField(null=True, blank=True)
    ended_at = models.DateTimeField(null=True, blank=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default="scheduled")

    agora_channel = models.CharField(max_length=255, unique=True)


    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.title} - {self.status}"




class MinuteBalance(models.Model):
    """
    Stores remaining seconds
    """
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="minute_balance")
    seconds_balance = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.user} - {self.seconds_balance}s"


class Gift(models.Model):
    sender = models.ForeignKey(User, on_delete=models.CASCADE, related_name="sent_gifts")
    receiver = models.ForeignKey(User, on_delete=models.CASCADE, related_name="received_gifts")
    stream = models.ForeignKey(LiveStream, on_delete=models.CASCADE)
    gift_name = models.CharField(max_length=50)
    amount = models.IntegerField()  # cost in cents
    created_at = models.DateTimeField(auto_now_add=True)

class ViewerSession(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    stream = models.ForeignKey(LiveStream, on_delete=models.CASCADE, related_name="viewers")
    joined_at = models.DateTimeField(auto_now_add=True)
    last_heartbeat = models.DateTimeField(auto_now=True)
    is_active = models.BooleanField(default=True)

    class Meta:
        unique_together = ("user", "stream")

class StreamEarning(models.Model):
    """
    Tracks total finalized earnings for a stream.
    This is the 'source of truth' balance for the streamer.
    """
    stream = models.OneToOneField(
        LiveStream,
        on_delete=models.CASCADE,
        related_name="earnings"
    )
    host = models.ForeignKey(User, on_delete=models.CASCADE)
    total_cents = models.BigIntegerField(default=0)  # stored in cents
    last_calculated_at = models.DateTimeField(null=True, blank=True)

    def __str__(self):
        return f"{self.stream} - {self.total_cents} cents"


class ViewerMinuteUsage(models.Model):
    """
    Ledger of every viewer-minute that actually generated revenue.
    This prevents double-counting and makes your system auditable.
    """
    stream = models.ForeignKey(LiveStream, on_delete=models.CASCADE)
    viewer = models.ForeignKey(User, on_delete=models.CASCADE)
    minute_timestamp = models.DateTimeField()  # which minute was billed
    billed = models.BooleanField(default=False)  # idempotency flag

    class Meta:
        unique_together = ("stream", "viewer", "minute_timestamp")