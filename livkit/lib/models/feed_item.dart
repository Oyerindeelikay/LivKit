class FeedItem {
  final String type; // live | fallback
  final String? streamId;
  final String? channelName;
  final String? streamer;
  final bool? isLive;
  final String? videoUrl;
  final String? agoraToken;

  FeedItem({
    required this.type,
    this.streamId,
    this.channelName,
    this.streamer,
    this.isLive,
    this.videoUrl,
    this.agoraToken,
  });

  factory FeedItem.fromStream(Map<String, dynamic> json) {
    return FeedItem(
      type: "live", // only live streams remain
      streamId: json["id"],
      channelName: json["channel_name"],
      streamer: json["streamer_identifier"],
      isLive: json["is_live"],
      videoUrl: json["recorded_video_url"],
      agoraToken: null,
    );
  }

  factory FeedItem.fromFallback(Map<String, dynamic> json) {
    return FeedItem(
      type: "fallback",
      videoUrl: json["video_url"],
      channelName: json["title"],
    );
  }
}
