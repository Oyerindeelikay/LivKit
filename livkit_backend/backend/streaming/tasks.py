from celery import shared_task
from django.utils import timezone
from datetime import timedelta
from .models import LiveSession

@shared_task
def auto_end_stuck_sessions():
    cutoff = timezone.now() - timedelta(hours=5)

    stuck_sessions = LiveSession.objects.filter(
        status="live",
        actual_start__lt=cutoff
    )

    for session in stuck_sessions:
        session.status = "ended"
        session.actual_end = timezone.now()
        session.save(update_fields=["status", "actual_end"])
