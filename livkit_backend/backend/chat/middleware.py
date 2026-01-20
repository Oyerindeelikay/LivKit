from urllib.parse import parse_qs
from django.contrib.auth import get_user_model
from django.contrib.auth.models import AnonymousUser
from django.conf import settings
from asgiref.sync import sync_to_async
import jwt
import logging

User = get_user_model()
logger = logging.getLogger("chat.middleware")


@sync_to_async
def get_user(user_id):
    try:
        return User.objects.get(id=user_id)
    except User.DoesNotExist:
        return AnonymousUser()


class JWTAuthMiddleware:
    def __init__(self, app):
        self.app = app

    async def __call__(self, scope, receive, send):
        scope["user"] = AnonymousUser()

        query_string = scope.get("query_string", b"").decode()
        params = parse_qs(query_string)
        token = params.get("token", [None])[0]

        if token:
            try:
                payload = jwt.decode(
                    token,
                    settings.SECRET_KEY,
                    algorithms=["HS256"],
                )

                user_id = payload.get("user_id")
                if user_id:
                    scope["user"] = await get_user(user_id)
                    logger.info(
                        f"WebSocket JWT valid: user={scope['user']}"
                    )

            except Exception as e:
                logger.warning(f"WebSocket JWT invalid: {e}")

        return await self.app(scope, receive, send)
