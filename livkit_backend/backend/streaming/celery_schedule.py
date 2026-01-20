from django_celery_beat.models import PeriodicTask, IntervalSchedule
import json

def setup_minute_deduction_job():
    schedule, _ = IntervalSchedule.objects.get_or_create(
        every=60,
        period=IntervalSchedule.SECONDS,
    )

    PeriodicTask.objects.get_or_create(
        name="Deduct viewer minutes every 60 seconds",
        defaults={
            "interval": schedule,
            "task": "streaming.tasks.deduct_viewer_minutes",
            "args": json.dumps([]),
        },
    )


def setup_earnings_job():
    schedule, _ = IntervalSchedule.objects.get_or_create(
        every=60,
        period=IntervalSchedule.SECONDS,
    )

    PeriodicTask.objects.get_or_create(
        name="Calculate streamer earnings every 60 seconds",
        defaults={
            "interval": schedule,
            "task": "streaming.tasks.calculate_stream_earnings",
            "args": json.dumps([]),
        },
    )
