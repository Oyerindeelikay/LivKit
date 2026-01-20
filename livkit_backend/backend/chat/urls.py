from django.urls import path
from .views import ConversationListView, MessageListView
from . import views

urlpatterns = [
    path("conversations/", ConversationListView.as_view()),
    path(
        "conversations/<uuid:conversation_id>/messages/",
        MessageListView.as_view(),
    ),

    path("friend_conversation/", views.get_or_create_friend_conversation, name="friend-conversation"),


    path('search/', views.search_users, name='search_users'),
    path('request/', views.send_friend_request, name='send_friend_request'),
    path('friend/', views.list_friends, name='list_friends'),

    path('requests/', views.pending_requests, name='pending_requests'),
    path('requests/respond/', views.respond_request, name='respond_request'),
]
