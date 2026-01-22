from django.contrib.auth.models import AbstractBaseUser, PermissionsMixin
from django.db import models
from django.utils import timezone
from .managers import UserManager




class User(AbstractBaseUser, PermissionsMixin):
    ROLE_CHOICES = (
        ('USER', 'User'),
        ('ADMIN_LIMITED', 'Limited Admin'),
        ('ADMIN_MAIN', 'Main Admin'),
    )

    username = models.CharField(
        max_length=30,
        unique=True,
        null=True,
        blank=True
    )


    email = models.EmailField(unique=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='USER')

    is_active = models.BooleanField(default=True)
    is_banned = models.BooleanField(default=False)

    # ⚠️ Legacy field (DO NOT USE FOR LOGIC ANYMORE)
    has_lifetime_access = models.BooleanField(default=False)

    date_joined = models.DateTimeField(default=timezone.now)

    is_staff = models.BooleanField(default=False)
    is_superuser = models.BooleanField(default=False)

    token_version = models.IntegerField(default=0)

    USERNAME_FIELD = 'email'
    REQUIRED_FIELDS = []

    objects = UserManager()

    def __str__(self):
        return self.email

    # ✅ SINGLE SOURCE OF TRUTH
    @property
    def lifetime_access(self):
        """
        True if user has an active entitlement
        (Stripe OR Play Store)
        """
        return hasattr(self, "entitlement") and self.entitlement.is_active



class UserProfile(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="profile"
    )

    display_name = models.CharField(
        max_length=100,
        blank=True
    )

    bio = models.TextField(
        blank=True
    )

    phone = models.CharField(
        max_length=20,
        blank=True
    )

    avatar = models.ImageField(
        upload_to="avatars/",
        blank=True,
        null=True
    )

    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.email} profile"
