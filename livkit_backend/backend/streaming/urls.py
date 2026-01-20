from django.urls import path
from . import views

urlpatterns = [
    path("live/streams/create/", views.create_stream),
    path("live/streams/<uuid:stream_id>/start/", views.start_stream),
    path("live/streams/<uuid:stream_id>/join/", views.join_stream),
    path("live/streams/<uuid:stream_id>/end/", views.end_stream),
    path("live/streams/", views.list_streams),

    # Payments / minutes
    path("payments/minutes/balance/", views.minutes_balance),
    path("live/streams/<uuid:stream_id>/agora-token/", views.get_viewer_token),
    path("streams/<uuid:stream_id>/earnings/", views.stream_earnings),
    path("payments/minutes/checkout/", views.StripeMinutesCheckoutView.as_view()),
    path("payments/minutes/webhook/", views.stripe_minutes_webhook),

]
