class FeedItem {
  final String type; // live | grace | fallback
  final String? streamId;
  final String? channelName;
  final String? streamer;
  final bool? isLive;
  final String? videoUrl;

  FeedItem({
    required this.type,
    this.streamId,
    this.channelName,
    this.streamer,
    this.isLive,
    this.videoUrl,
  });

  /// From LiveStreamSerializer
  factory FeedItem.fromStream(Map<String, dynamic> json) {
    return FeedItem(
      type: json["feed_type"],
      streamId: json["id"],
      channelName: json["channel_name"],
      streamer: json["streamer_identifier"],
      isLive: json["is_live"],
      videoUrl: json["recorded_video_url"],  // ADD THIS
    );
  }

  /// From FallbackVideo
  factory FeedItem.fromFallback(Map<String, dynamic> json) {
    return FeedItem(
      type: "fallback",
      videoUrl: json["video_url"],
      channelName: json["title"],
    );
  }
}
