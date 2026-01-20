from django.urls import path
from . import views

urlpatterns = [
    path("stripe/create-checkout/", views.StripeCreateCheckoutView.as_view()),
    path("stripe/webhook/", views.stripe_webhook),

    path("google/verify/", views.GoogleVerifyPurchaseView.as_view()),
]
