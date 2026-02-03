from django.contrib import admin
from .models import FallbackVideo, LiveStream

@admin.register(FallbackVideo)
class FallbackVideoAdmin(admin.ModelAdmin):
    list_display = ("title", "video_url", "is_active", "weight")
    list_editable = ("is_active", "weight")
    search_fields = ("title", "video_url")

# Optional: also register LiveStream for debugging
@admin.register(LiveStream)
class LiveStreamAdmin(admin.ModelAdmin):
    list_display = ("channel_name", "streamer", "is_live", "started_at", "ended_at", "total_views")
    list_filter = ("is_live",)
    search_fields = ("channel_name",)
