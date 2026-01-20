from functools import wraps
from django.shortcuts import redirect
from rest_framework_simplejwt.authentication import JWTAuthentication
from rest_framework.exceptions import AuthenticationFailed
from rest_framework_simplejwt.exceptions import TokenError



def jwt_required(view_func):
    @wraps(view_func)
    def wrapper(request, *args, **kwargs):
        raw_token = request.COOKIES.get("access")

        if not raw_token:
            return redirect("signin")

        jwt_auth = JWTAuthentication()

        try:
            validated_token = jwt_auth.get_validated_token(raw_token)
            user = jwt_auth.get_user(validated_token)

            # 🔒 Enforce your domain rules
            if getattr(user, "is_banned", False):
                return redirect("signin")

        except AuthenticationFailed:
            return redirect("signin")
        except Exception:
            return redirect("signin")


        except TokenError:
            response = redirect("signin")
            response.delete_cookie("access")
            response.delete_cookie("refresh")
            return response


        request.user = user
        return view_func(request, *args, **kwargs)

    return wrapper
