from celery import shared_task
from django.utils.timezone import now, timedelta
from channels.layers import get_channel_layer
from asgiref.sync import async_to_sync
from .models import ViewerSession, MinuteBalance, LiveStream
from .models import ViewerMinuteUsage, StreamEarning
from django.conf import settings

@shared_task(bind=True, autoretry_for=(Exception,), retry_backoff=5, retry_kwargs={"max_retries": 5})
def deduct_viewer_minutes():
    """
    Runs every 60 seconds:
    - Deducts 60 seconds from active viewers
    - Removes viewers with 0 balance
    - Sends WebSocket event to kick them
    """

    channel_layer = get_channel_layer()

    # Find all ACTIVE viewer sessions
    active_sessions = ViewerSession.objects.filter(is_active=True)

    for session in active_sessions:
        user = session.user
        stream = session.stream

        try:
            balance = MinuteBalance.objects.get(user=user)
        except MinuteBalance.DoesNotExist:
            # No balance → kick immediately
            session.is_active = False
            session.save()
            continue

        # Deduct 60 seconds
        balance.seconds_balance -= 60
        balance.save()

        # Record that THIS viewer generated 1 billable minute
        ViewerMinuteUsage.objects.get_or_create(
            stream=stream,
            viewer=user,
            minute_timestamp=now().replace(second=0, microsecond=0),
        )
                # If balance is now <= 0, kick the viewer
        if balance.seconds_balance <= 0:
            session.is_active = False
            session.save()

            async_to_sync(channel_layer.group_send)(
                f"stream_{stream.id}",
                {
                    "type": "minutes_exhausted",
                    "user_id": user.id,
                    "username": user.username,
                },
            )



@shared_task(bind=True, autoretry_for=(Exception,), retry_backoff=5, retry_kwargs={"max_retries": 5})
def calculate_stream_earnings():
    """
    Periodically finalizes earnings from ViewerMinuteUsage.
    Safe, idempotent, and crash-resistant.
    """

    streams = LiveStream.objects.filter(status="live")

    for stream in streams:
        earning, _ = StreamEarning.objects.get_or_create(
            stream=stream,
            host=stream.host,
        )

        # Get all UNBILLED minutes for this stream
        unbilled_minutes = ViewerMinuteUsage.objects.filter(
            stream=stream,
            billed=False,
        )

        minute_count = unbilled_minutes.count()

        if minute_count == 0:
            continue

        # Convert minutes → cents
        added_cents = minute_count * settings.EARNINGS_CENTS_PER_VIEWER_MINUTE

        # Update total
        earning.total_cents += added_cents
        earning.last_calculated_at = now()
        earning.save()

        # Mark these minutes as billed (so we never double count)
        unbilled_minutes.update(billed=True)
