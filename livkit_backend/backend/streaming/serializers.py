from rest_framework import serializers
from .models import LiveStream


class LiveStreamSerializer(serializers.ModelSerializer):
    streamer_username = serializers.CharField(
        source="streamer.username",
        read_only=True
    )
    total_earnings = serializers.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0
    )


    class Meta:
        model = LiveStream
        fields = [
            "id",
            "channel_name",
            "streamer_username",
            "is_live",
            "total_views",
            "total_earnings",
            "started_at",
        ]

