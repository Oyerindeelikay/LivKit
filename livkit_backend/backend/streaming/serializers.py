from rest_framework import serializers
from .models import LiveStream


class LiveStreamSerializer(serializers.ModelSerializer):
    streamer_identifier = serializers.SerializerMethodField()

    class Meta:
        model = LiveStream
        fields = [
            "id",
            "channel_name",
            "streamer_identifier",
            "is_live",
            "total_views",
            "total_earnings",
            "started_at",
        ]

    def get_streamer_identifier(self, obj):
        """
        Safely return an identifier for the streamer.
        Works with custom user models.
        """
        streamer = obj.streamer

        # Prefer email if it exists
        if hasattr(streamer, "email") and streamer.email:
            return streamer.email

        # Fallback to user ID (always exists)
        return str(streamer.id)
