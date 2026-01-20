from django.conf import settings
import time
from AccessToken import (
    AccessToken,
    kJoinChannel,
    kPublishAudioStream,
    kPublishVideoStream,
    kPublishDataStream,
)

# Define roles (since your AccessToken file DOES NOT)
Role_Attendee = 0   # same as publisher
Role_Publisher = 1  # broadcaster (host)
Role_Subscriber = 2 # audience (viewer)
Role_Admin = 101    # deprecated

def generate_agora_token(channel_name: str, uid: int, is_host: bool) -> str:
    if not settings.AGORA_APP_ID or not settings.AGORA_APP_CERTIFICATE:
        raise Exception("Agora credentials are not configured in settings.py")

    role = Role_Publisher if is_host else Role_Subscriber
    privilege_expire = int(time.time()) + settings.AGORA_TOKEN_TTL

    token = AccessToken(
        settings.AGORA_APP_ID,
        settings.AGORA_APP_CERTIFICATE,
        channel_name,
        uid,
    )

    # Everyone must join channel
    token.addPrivilege(kJoinChannel, privilege_expire)

    # If host, allow publishing
    if role == Role_Publisher:
        token.addPrivilege(kPublishVideoStream, privilege_expire)
        token.addPrivilege(kPublishAudioStream, privilege_expire)
        token.addPrivilege(kPublishDataStream, privilege_expire)

    return token.build()
