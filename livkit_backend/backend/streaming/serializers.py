from rest_framework import serializers
from .models import LiveStream


class LiveStreamSerializer(serializers.ModelSerializer):
    streamer_username = serializers.CharField(
        source="streamer.username",
        read_only=True
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
