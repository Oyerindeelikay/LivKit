// lib/services/gift_ws_service.dart
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef GiftCallback = void Function(Map<String, dynamic> giftData);

class GiftWsService {
  WebSocketChannel? _channel;

  void connect({
    required int streamId,
    required String accessToken,
    required GiftCallback onGiftReceived,
  }) {
    final uri = Uri.parse(
      "wss://livkit.onrender.com/ws/streams/$streamId/?token=$accessToken",
    );

    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen((event) {
      final data = jsonDecode(event);

      if (data["type"] == "gift_event") {
        onGiftReceived(data);
      }
    });
  }

  void disconnect() {
    _channel?.sink.close();
    _channel = null;
  }
}
