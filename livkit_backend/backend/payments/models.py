from django.conf import settings
from django.db import models
from django.utils import timezone


User = settings.AUTH_USER_MODEL
class Entitlement(models.Model):
    SOURCE_CHOICES = (
        ("stripe", "Stripe"),
        ("playstore", "Google Play"),
    )

    user = models.OneToOneField(
        settings.AUTH_USER_MODEL,
        related_name="entitlement",
        on_delete=models.CASCADE
    )

    is_active = models.BooleanField(default=False)

    source = models.CharField(max_length=20, choices=SOURCE_CHOICES, null=True, blank=True)
    transaction_id = models.CharField(max_length=255, unique=True, null=True, blank=True)

    activated_at = models.DateTimeField(null=True, blank=True)

    def activate(self, source, transaction_id):
        if self.transaction_id == transaction_id:
            return
    
        self.is_active = True
        self.source = source
        self.transaction_id = transaction_id
        self.activated_at = timezone.now()
        self.save()
    
        user = self.user
        user.is_premium = True
        user.has_lifetime_access = True
        user.save()


    def __str__(self):
        return f"{self.user.email} → {self.is_active}"


class PaymentLog(models.Model):
    """
    Debug + audit trail (never trust logs for access control)
    """
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.SET_NULL, null=True)
    provider = models.CharField(max_length=20)
    event = models.CharField(max_length=50)
    reference = models.CharField(max_length=255, null=True, blank=True)
    payload = models.JSONField(default=dict)
    created_at = models.DateTimeField(auto_now_add=True)


# ==============================
# MINUTES (FOR VIEWERS)
# ==============================
class MinuteWallet(models.Model):
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name="minute_wallet"
    )
    seconds_balance = models.BigIntegerField(default=0)  # use seconds, not minutes
    created_at = models.DateTimeField(auto_now_add=True)

    def can_watch(self, seconds: int) -> bool:
        return self.seconds_balance >= seconds

    def deduct(self, seconds: int):
        if seconds > self.seconds_balance:
            raise ValueError("Insufficient watch time")
        self.seconds_balance -= seconds
        self.save(update_fields=["seconds_balance"])

    def add(self, seconds: int):
        self.seconds_balance += seconds
        self.save(update_fields=["seconds_balance"])

    def reserve_for_stream(self, seconds: int):
        if seconds > self.seconds_balance:
            raise ValueError("Insufficient watch time")

        self.seconds_balance -= seconds
        self.save(update_fields=["seconds_balance"])

        MinuteLedger.objects.create(
            user=self.user,
            action="watch_deduction",
            seconds=seconds
        )


    def refund_from_stream(self, seconds: int):
        """
        Return unused seconds after disconnect.
        """
        self.seconds_balance += seconds
        self.save(update_fields=["seconds_balance"])

    def __str__(self):
        return f"{self.user} - {self.seconds_balance}s"



class MinuteLedger(models.Model):
    ACTION_CHOICES = (
        ("purchase", "Purchase"),
        ("watch_deduction", "Watch Deduction"),
        ("refund", "Refund"),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    action = models.CharField(max_length=20, choices=ACTION_CHOICES)
    seconds = models.IntegerField()

    # --- ADD THESE ---
    stripe_event_id = models.CharField(max_length=255, null=True, blank=True, unique=True)
    stripe_price_id = models.CharField(max_length=255, null=True, blank=True)
    # -------------

    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.action} - {self.seconds}s"


# ==============================
# COINS (FOR GIFTS)
# ==============================

class CoinWallet(models.Model):
    user = models.OneToOneField(User, on_delete=models.CASCADE, related_name="coin_wallet")
    balance = models.BigIntegerField(default=0)
    created_at = models.DateTimeField(auto_now_add=True)

    def deduct(self, amount: int):
        if amount > self.balance:
            raise ValueError("Insufficient coins")
        self.balance -= amount
        self.save(update_fields=["balance"])

    def add(self, amount: int):
        self.balance += amount
        self.save(update_fields=["balance"])

    def __str__(self):
        return f"{self.user} - {self.balance} coins"


class CoinLedger(models.Model):
    ACTION_CHOICES = (
        ("purchase", "Purchase"),
        ("gift", "Gift"),
        ("refund", "Refund"),
    )

    user = models.ForeignKey(User, on_delete=models.CASCADE)
    action = models.CharField(max_length=20, choices=ACTION_CHOICES)
    amount = models.IntegerField()
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.action} - {self.amount} coins"


# ==============================
# STREAMER EARNINGS (CRUCIAL)
# ==============================

class StreamEarning(models.Model):
    streamer = models.ForeignKey(User, on_delete=models.CASCADE, related_name="earnings")
    stream_id = models.CharField(max_length=255)  # link to livestream.Stream.id
    minutes_watched = models.FloatField(default=0)
    gifts_received = models.BigIntegerField(default=0)
    platform_cut = models.FloatField(default=0)  # percentage stored as decimal (e.g. 0.30 = 30%)
    payout_amount = models.BigIntegerField()  # store in cents
    finalized = models.BooleanField(default=False)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Earnings for {self.streamer} - Stream {self.stream_id}"
