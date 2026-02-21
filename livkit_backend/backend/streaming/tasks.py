from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from django.db import transaction
from .models import LiveStream

STREAM_HEARTBEAT_TIMEOUT = 60  # seconds


@shared_task
def auto_end_dead_streams():
    timeout_time = timezone.now() - timedelta(seconds=STREAM_HEARTBEAT_TIMEOUT)

    dead_streams = LiveStream.objects.filter(
        is_live=True,
        last_heartbeat__lt=timeout_time
    )

    for stream in dead_streams:
        with transaction.atomic():
            stream.is_live = False
            stream.ended_at = timezone.now()
            stream.save(update_fields=["is_live", "ended_at"])

            print(f"[AUTO END] Stream {stream.id} ended due to heartbeat timeout")
