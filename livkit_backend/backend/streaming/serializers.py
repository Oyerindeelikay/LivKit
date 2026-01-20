from rest_framework import serializers
from .models import LiveStream, Gift, MinuteBalance
from .models import StreamEarning

class LiveStreamSerializer(serializers.ModelSerializer):
    is_live = serializers.SerializerMethodField()
    is_ended = serializers.SerializerMethodField()

    class Meta:
        model = LiveStream
        fields = "__all__"

    def get_is_live(self, obj):
        return obj.status == "live"

    def get_is_ended(self, obj):
        return obj.status == "ended"




class GiftSerializer(serializers.ModelSerializer):
    class Meta:
        model = Gift
        fields = "__all__"


class MinuteBalanceSerializer(serializers.ModelSerializer):
    class Meta:
        model = MinuteBalance
        fields = ["seconds_balance"]

class StreamEarningSerializer(serializers.ModelSerializer):
    class Meta:
        model = StreamEarning
        fields = [
            "stream",
            "host",
            "total_cents",
            "last_calculated_at",
        ]
