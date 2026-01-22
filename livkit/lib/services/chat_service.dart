import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'auth_service.dart';
import '../constants/chat_constants.dart';

enum SocketState {
  disconnected,
  connecting,
  connected,
}

class ChatService {
  final String conversationId;

  WebSocketChannel? _channel;
  SocketState _state = SocketState.disconnected;
  bool _disposed = false;

  Timer? _reconnectTimer;

  final List<Map<String, dynamic>> _outbox = [];

  final StreamController<Map<String, dynamic>> _events =
      StreamController.broadcast();

  Stream<Map<String, dynamic>> get events => _events.stream;

  ChatService({required String conversationId})
      : conversationId = _sanitizeConversationId(conversationId);

  // ─────────────────────────────────────────────
  // Conversation ID guard
  // ─────────────────────────────────────────────

  static String _sanitizeConversationId(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{4}-'
      r'[0-9a-fA-F]{12}$',
    );

    return uuidRegex.hasMatch(value)
        ? value
        : ChatConstants.globalConversationId;
  }

  // ─────────────────────────────────────────────
  // Connection
  // ─────────────────────────────────────────────

  Future<void> connect({bool force = false}) async {
    if (_disposed) return;
    if (_state == SocketState.connected && !force) return;
    if (_state == SocketState.connecting) return;

    _state = SocketState.connecting;
    _reconnectTimer?.cancel();

    try {
      final auth = AuthService();
      await auth.refreshIfNeeded();
      final token = await auth.getAccessToken();

      if (token == null) {
        throw Exception("JWT missing");
      }

      final isProd = bool.fromEnvironment('dart.vm.product');
      final base = isProd
          ? 'wss://livkit.onrender.com'
          : 'ws://127.0.0.1:8000';

      final uri = Uri.parse(
        '$base/ws/chat/$conversationId/?token=$token',
      );

      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        _onMessage,
        onError: _onDisconnect,
        onDone: _onDisconnect,
        cancelOnError: true,
      );

      _state = SocketState.connected;

      _flushOutbox();
    } catch (_) {
      _state = SocketState.disconnected;
      _scheduleReconnect();
    }
  }

  void _onDisconnect([_]) {
    if (_disposed) return;

    _channel = null;
    _state = SocketState.disconnected;

    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_disposed) return;
    if (_reconnectTimer != null) return;

    _reconnectTimer = Timer(const Duration(seconds: 3), () {
      _reconnectTimer = null;
      if (!_disposed) {
        connect(force: true);
      }
    });
  }

  // ─────────────────────────────────────────────
  // Messaging
  // ─────────────────────────────────────────────

  void send(Map<String, dynamic> payload) {
    if (_disposed) return;

    if (_state != SocketState.connected || _channel == null) {
      _outbox.add(payload);
      connect();
      return;
    }

    _sendNow(payload);
  }

  void _sendNow(Map<String, dynamic> payload) {
    try {
      _channel!.sink.add(json.encode(payload));
    } catch (_) {
      _outbox.add(payload);
      _onDisconnect();
    }
  }

  void _flushOutbox() {
    if (_outbox.isEmpty) return;

    for (final msg in List<Map<String, dynamic>>.from(_outbox)) {
      _sendNow(msg);
    }
    _outbox.clear();
  }

  // ─────────────────────────────────────────────
  // Incoming
  // ─────────────────────────────────────────────

  void _onMessage(dynamic data) {
    if (_disposed) return;

    try {
      final decoded = json.decode(data);

      if (decoded is! Map<String, dynamic>) return;
      if (!decoded.containsKey("type")) return;

      _events.add(decoded);
    } catch (_) {
      // swallow malformed frames
    }
  }

  // ─────────────────────────────────────────────
  // Cleanup
  // ─────────────────────────────────────────────

  void dispose() {
    _disposed = true;

    _reconnectTimer?.cancel();
    _outbox.clear();

    _channel?.sink.close();
    _events.close();
  }
}
