// lib/services/live_ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';

typedef CommentCallback = void Function(String username, String message);
typedef ViewerCallback = void Function(int count);
typedef GenericEventCallback = void Function(Map<String, dynamic> data);

class LiveWsService {
  WebSocketChannel? _channel;

  bool _connected = false;
  bool get isConnected => _connected;

  CommentCallback? onComment;
  ViewerCallback? onViewerUpdate;
  GenericEventCallback? onGenericEvent;



  void disconnect() {
    if (!_connected) return;
    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }

  /// 🔌 Connect to live stream WS
  void joinStream({
    required String streamId,
    required String accessToken,
    CommentCallback? onComment,
    ViewerCallback? onViewerUpdate,
    GenericEventCallback? onGenericEvent,
  }) {
    if (_connected) return;

    final uri = Uri.parse(
      "ws://127.0.0.1:8000/ws/streams/$streamId/?token=$accessToken",
    );

    _channel = WebSocketChannel.connect(uri);

    _connected = true;
    this.onComment = onComment;
    this.onViewerUpdate = onViewerUpdate;
    this.onGenericEvent = onGenericEvent;

    _channel!.stream.listen(
      (event) {
        try {
          final data = jsonDecode(event);

          // 👀 Viewer count update
          if (data["type"] == "viewer_count") {
            onViewerUpdate?.call(data["count"] ?? 0);
          }

          // 💬 New comment
          else if (data["type"] == "comment") {
            onComment?.call(
              data["username"] ?? "Anonymous",
              data["message"] ?? "",
            );
          }

          // 🔄 Generic event
          else {
            onGenericEvent?.call(data);
          }
        } catch (e) {
          debugPrint("WS parse error: $e");
        }
      },
      onError: (error) {
        debugPrint("Live WS error: $error");
        disconnect();
      },
      onDone: () {
        debugPrint("Live WS closed");
        disconnect();
      },
    );
  }

  /// 📤 Send comment/message
  void sendComment(String streamId, String message) {
    if (!_connected || _channel == null) return;

    _channel!.sink.add(jsonEncode({
      "type": "comment",
      "stream_id": streamId,
      "message": message,
    }));
  }

  /// ❌ Disconnect safely
  void leaveStream(String streamId) {
    if (!_connected) return;

    _channel?.sink.add(jsonEncode({
      "type": "leave",
      "stream_id": streamId,
    }));

    _channel?.sink.close();
    _channel = null;
    _connected = false;
  }
}
