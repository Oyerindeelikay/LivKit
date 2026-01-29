from rest_framework import serializers


class ScheduleLiveSerializer(serializers.Serializer):
    room_id = serializers.IntegerField()
    scheduled_start = serializers.DateTimeField()

    def validate_scheduled_start(self, value):
        """
        Prevent scheduling lives in the past
        """
        from django.utils import timezone

        if value <= timezone.now():
            print("Invalid scheduled_start: in the past")  # debug comment
            raise serializers.ValidationError(
                "Scheduled start must be in the future."
            )

        print("Scheduled start time validated")  # debug comment
        return value




class ViewerJoinSerializer(serializers.Serializer):
    session_id = serializers.IntegerField()
