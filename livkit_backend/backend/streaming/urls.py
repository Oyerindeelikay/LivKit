from django.urls import path
from .views import ScheduleLiveView, GoLiveView,EndLiveView,HMSWebhookView, ViewerJoinLiveView

urlpatterns = [
    path("schedule/", ScheduleLiveView.as_view(), name="schedule-live"),
    path("golive/", GoLiveView.as_view(), name="go-live"),

    path("end/", EndLiveView.as_view(), name="end-live"),
    path("hms/webhook/", HMSWebhookView.as_view(), name="hms-webhook"),
    path("viewer/join/", ViewerJoinLiveView.as_view(), name="viewer-join-live"),
]
