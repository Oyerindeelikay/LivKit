import jwt
import time
from django.conf import settings

import hmac
import hashlib


HMS_ACCESS_KEY = settings.HMS_ACCESS_KEY
HMS_SECRET = settings.HMS_SECRET



def verify_hms_signature(request):
    signature = request.headers.get("X-HMS-Signature")
    if not signature:
        return False

    computed = hmac.new(
        key=settings.HMS_SECRET.encode(),
        msg=request.body,
        digestmod=hashlib.sha256,
    ).hexdigest()

    return hmac.compare_digest(computed, signature)


def generate_hms_token(user_id, room_id, role, ttl=3600):
    payload = {
        "access_key": HMS_ACCESS_KEY,
        "room_id": room_id,
        "user_id": str(user_id),
        "role": role,
        "type": "app",
        "version": 2,
        "iat": int(time.time()),
        "exp": int(time.time()) + ttl,
    }

    token = jwt.encode(payload, HMS_SECRET, algorithm="HS256")
    print("Generated 100ms token")  # debug comment
    return token
