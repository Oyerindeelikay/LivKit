from rest_framework import serializers
from django.utils import timezone
from .models import LiveStream


class LiveStreamSerializer(serializers.ModelSerializer):
    streamer_identifier = serializers.SerializerMethodField()
    feed_type = serializers.SerializerMethodField()

    class Meta:
        model = LiveStream
        fields = [
            "id",
            "channel_name",
            "streamer_identifier",
            "is_live",
            "started_at",
            "ended_at",
            "total_views",
            "total_earnings",
            "feed_type",
        ]

    def get_streamer_identifier(self, obj):
        streamer = obj.streamer

        if hasattr(streamer, "email") and streamer.email:
            return streamer.email

        return str(streamer.id)

    def get_feed_type(self, obj):
        """
        Explicit feed classification.
        Frontend MUST NOT guess.
        """
        if obj.is_live:
            return "live"

        if obj.ended_at and obj.is_in_grace_period:
            return "grace"

        return "expired"
