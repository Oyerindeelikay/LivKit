from django.urls import path
from .views import (
    CreateLiveStreamView,
    JoinLiveStreamView,
    LeaveLiveStreamView,
    StreamHeartbeatView,
    EndLiveStreamView,
    ActiveLiveStreamView,

    LiveFeedView,
)

urlpatterns = [
    path("create/", CreateLiveStreamView.as_view()),
    path("<uuid:stream_id>/join/", JoinLiveStreamView.as_view()),
    path("<uuid:stream_id>/leave/", LeaveLiveStreamView.as_view()),
    path(
        "<uuid:stream_id>/heartbeat/",
        StreamHeartbeatView.as_view()
    ),
    path(
        "<uuid:stream_id>/end/",
        EndLiveStreamView.as_view(),
    ),
    path("active/", ActiveLiveStreamView.as_view(), name="active_live_stream"),
    path("feed/", LiveFeedView.as_view(), name="live_feed"),



]
