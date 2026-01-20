from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from .serializers import RegisterSerializer, AdminLoginSerializer
from django.contrib.auth import authenticate
from .tokens import get_tokens_for_user, create_admin_tokens
from rest_framework.permissions import AllowAny
from rest_framework.decorators import api_view, permission_classes


from .serializers import MeSerializer


from rest_framework.permissions import IsAuthenticated
from accounts.permissions import (
    IsAuthenticatedAndNotBanned,
    HasLifetimeAccess
)

from .models import UserProfile

from accounts.permissions import IsAdmin

from accounts.permissions import IsMainAdmin



from rest_framework_simplejwt.authentication import JWTAuthentication


from .serializers import UserProfileNestedSerializer











from django.contrib.auth import get_user_model
from django.utils.http import urlsafe_base64_encode, urlsafe_base64_decode
from django.utils.encoding import force_bytes, force_str
from django.core.mail import send_mail

from .tokens import password_reset_token
from .serializers import ForgotPasswordSerializer, ResetPasswordSerializer

User = get_user_model()

@api_view(["POST"])

@permission_classes([AllowAny])
def forgot_password(request):
    serializer = ForgotPasswordSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    email = serializer.validated_data["email"]
    user = User.objects.filter(email=email).first()

    if user:
        uid = urlsafe_base64_encode(force_bytes(user.pk))
        token = password_reset_token.make_token(user)

        reset_link = f"https://yourapp.com/reset-password?uid={uid}&token={token}"

        send_mail(
            subject="Reset your password",
            message=f"Click here to reset your password:\n{reset_link}",
            from_email="no-reply@yourapp.com",
            recipient_list=[email],
        )

    # Always return success (security best practice)
    return Response({"message": "If the email exists, a reset link has been sent."})





@api_view(["POST"])
@permission_classes([AllowAny])
def reset_password(request):
    serializer = ResetPasswordSerializer(data=request.data)
    serializer.is_valid(raise_exception=True)

    uid = serializer.validated_data["uid"]
    token = serializer.validated_data["token"]
    new_password = serializer.validated_data["new_password"]

    try:
        user_id = force_str(urlsafe_base64_decode(uid))
        user = User.objects.get(pk=user_id)
    except Exception:
        return Response({"error": "Invalid link"}, status=400)

    if not password_reset_token.check_token(user, token):
        return Response({"error": "Token expired or invalid"}, status=400)

    user.set_password(new_password)
    user.token_version += 1  # 🔥 invalidates all JWTs
    user.save()

    return Response({"message": "Password reset successful"})









class UploadAvatarView(APIView):
    permission_classes = [IsAuthenticated]

    def post(self, request):
        user = request.user
        profile, _ = UserProfile.objects.get_or_create(user=user)

        avatar = request.FILES.get("avatar")
        if not avatar:
            return Response(
                {"error": "Avatar file is required"},
                status=status.HTTP_400_BAD_REQUEST
            )

        profile.avatar = avatar
        profile.save()

        serializer = UserProfileNestedSerializer(profile)
        return Response(serializer.data, status=status.HTTP_200_OK)


class UpdateProfileView(APIView):
    permission_classes = [IsAuthenticated]

    def put(self, request):
        user = request.user
        profile, _ = UserProfile.objects.get_or_create(user=user)

        # Update fields from request.data
        profile.display_name = request.data.get("display_name", profile.display_name)
        profile.bio = request.data.get("bio", profile.bio)
        profile.phone = request.data.get("phone", profile.phone)
        profile.save()

        serializer = UserProfileNestedSerializer(profile)
        return Response(serializer.data, status=status.HTTP_200_OK)


class MeView(APIView):
    permission_classes = [IsAuthenticated]


    def get(self, request):
        user = request.user
        return Response({
            "email": user.email,
            "role": user.role,
            "username": user.username,
            "is_banned": user.is_banned,
            "has_lifetime_access": getattr(user.entitlement, "is_active", False)
        })



class Me2View(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request):
        serializer = MeSerializer(
            request.user,
            context={"request": request}
        )
        return Response(serializer.data)




class AdminLogoutView(APIView):
    permission_classes = [IsAdmin]

    def post(self, request):
        user = request.user
        revoke_admin_tokens(user)
        return Response({"detail": "Logged out"})


class AdminTokenRefreshView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        refresh_token = request.data.get("refresh")

        if not refresh_token:
            return Response({"detail": "Missing refresh token"}, status=400)

        try:
            token = RefreshToken(refresh_token)
        except Exception:
            return Response({"detail": "Invalid refresh token"}, status=401)

        if token.get("token_type") != "admin":
            return Response({"detail": "Invalid token type"}, status=403)

        user_id = token["user_id"]
        user = User.objects.get(id=user_id)

        if token.get("token_version") != user.token_version:
            return Response({"detail": "Token revoked"}, status=401)

        new_access = token.access_token
        return Response({"access": str(new_access)})


class AdminLoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        serializer = AdminLoginSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        user = serializer.validated_data
        tokens = create_admin_tokens(user)

        return Response({
            "access": tokens["access"],
            "refresh": tokens["refresh"],
            "role": user.role,
        })


class MainAdminView(APIView):
    permission_classes = [
        IsAuthenticated,
        IsAuthenticatedAndNotBanned,
        IsMainAdmin
    ]

    def get(self, request):
        return Response({"message": "Main admin access"})


class LimitedAdminView(APIView):
    permission_classes = [
        IsAuthenticated,
        IsAuthenticatedAndNotBanned,
        IsAdmin
    ]

    def get(self, request):
        return Response({"message": "Limited admin access"})


class UserDashboardView(APIView):
    permission_classes = [
        IsAuthenticated,
        IsAuthenticatedAndNotBanned,
        HasLifetimeAccess
    ]

    def get(self, request):
        return Response({"message": "Welcome user"})


class LoginView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        email = request.data.get('email')
        password = request.data.get('password')

        user = authenticate(email=email, password=password)



        if not user or not user.is_active:
            return Response(
                {"error": "Invalid credentials"},
                status=status.HTTP_401_UNAUTHORIZED
            )


        if user.is_banned:
            return Response(
                {"error": "Account banned"},
                status=status.HTTP_403_FORBIDDEN
            )

        tokens = get_tokens_for_user(user)
        return Response(tokens)


class RegisterView(APIView):
    permission_classes = [AllowAny]
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        if serializer.is_valid():
            serializer.save()
            return Response({"message": "User created"}, status=status.HTTP_201_CREATED)
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
