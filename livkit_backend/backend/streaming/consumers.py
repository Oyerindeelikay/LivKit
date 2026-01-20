import json
from channels.generic.websocket import AsyncWebsocketConsumer
from django.contrib.auth import get_user_model
from .models import LiveStream, ViewerSession, MinuteBalance, Gift

from .models import ViewerSession
User = get_user_model()

class LiveStreamConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        self.stream_id = self.scope["url_route"]["kwargs"]["stream_id"]
        self.room_group_name = f"stream_{self.stream_id}"

        await self.channel_layer.group_add(
            self.room_group_name,
            self.channel_name
        )

        await self.accept()



    async def disconnect(self, close_code):
        try:
            ViewerSession.objects.filter(
                user=self.scope["user"],
                stream_id=self.stream_id
            ).update(is_active=False)
        except Exception:
            pass

        await self.channel_layer.group_discard(
            self.room_group_name,
            self.channel_name
        )



    async def minutes_exhausted(self, event):
        await self.send(text_data=json.dumps({
            "type": "minutes_exhausted",
            "user_id": event["user_id"],
            "username": event["username"],
        }))


    async def receive(self, text_data):
        data = json.loads(text_data)
        event_type = data.get("type")

        if event_type == "comment":
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    "type": "broadcast_comment",
                    "username": self.scope["user"].username,
                    "message": data["message"],
                }
            )

        elif event_type == "gift":
            await self.channel_layer.group_send(
                self.room_group_name,
                {
                    "type": "broadcast_gift",
                    "sender": self.scope["user"].username,
                    "gift_name": data["gift_name"],
                }
            )

    async def broadcast_comment(self, event):
        await self.send(text_data=json.dumps({
            "type": "comment",
            "username": event["username"],
            "message": event["message"],
        }))

    async def broadcast_gift(self, event):
        await self.send(text_data=json.dumps({
            "type": "gift_event",
            "sender": event["sender"],
            "gift_name": event["gift_name"],
        }))
