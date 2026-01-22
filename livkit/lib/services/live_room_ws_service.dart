// lib/services/live_room_ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

/// Event callbacks
typedef ViewerCountCallback = void Function(int count);
typedef CommentCallback = void Function(String username, String message);
typedef GiftCallback = void Function(Map<String, dynamic> gift);
typedef MinutesEventCallback = void Function();
typedef GenericEventCallback = void Function(Map<String, dynamic> data);

class LiveRoomWsService {
  WebSocketChannel? _channel;
  bool _connected = false;

  bool get isConnected => _connected;

  ViewerCountCallback? onViewerCount;
  CommentCallback? onComment;
  GiftCallback? onGift;
  MinutesEventCallback? onMinutesExhausted;
  GenericEventCallback? onGenericEvent;

  /// 🔌 Connect to live room WS
  void connect({
    required String streamId,
    required String accessToken,
    ViewerCountCallback? onViewerCount,
    CommentCallback? onComment,
    GiftCallback? onGift,
    MinutesEventCallback? onMinutesExhausted,
    GenericEventCallback? onGenericEvent,
  }) {
    if (_connected) return;

    final uri = Uri.parse(
      "wss://livkit.onrender.com/ws/streams/$streamId/?token=$accessToken",
    );

    _channel = WebSocketChannel.connect(uri);
    _connected = true;

    this.onViewerCount = onViewerCount;
    this.onComment = onComment;
    this.onGift = onGift;
    this.onMinutesExhausted = onMinutesExhausted;
    this.onGenericEvent = onGenericEvent;

    _channel!.stream.listen(
      _handleEvent,
      onError: (error) {
        debugPrint("LiveRoom WS error: $error");
        disconnect();
      },
      onDone: () {
        debugPrint("LiveRoom WS closed");
        disconnect();
      },
    );
  }

  /// 🧠 Central event router
  void _handleEvent(dynamic event) {
    try {
      final data = jsonDecode(event);
      final type = data["type"];

      switch (type) {
        case "viewer_count":
          onViewerCount?.call(data["count"] ?? 0);
          break;

        case "comment":
          onComment?.call(
            data["username"] ?? "Anonymous",
            data["message"] ?? "",
          );
          break;

        case "gift_event":
          onGift?.call(data);
          break;

        case "minutes_exhausted":
          onMinutesExhausted?.call();
          break;

        default:
          onGenericEvent?.call(data);
      }
    } catch (e) {
      debugPrint("LiveRoom WS parse error: $e");
    }
  }

  /// 📤 Send comment
  void sendComment({
    required String streamId,
    required String message,
  }) {
    if (!_connected || _channel == null) return;

    _channel!.sink.add(jsonEncode({
      "type": "comment",
      "stream_id": streamId,
      "message": message,
    }));
  }

  /// ❌ Disconnect safely
  void disconnect() {
    if (!_connected) return;
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }
}
