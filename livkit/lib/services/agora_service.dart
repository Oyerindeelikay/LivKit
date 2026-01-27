// lib/services/agora_service.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/foundation.dart';

class AgoraService {
  RtcEngine? _engine;
  bool _initialized = false;
  bool _joined = false;

  bool get isInitialized => _initialized;
  bool get isJoined => _joined;

  RtcEngine get engine {
    if (_engine == null || !_initialized) {
      throw Exception("Agora engine not initialized");
    }
    return _engine!;
  }

  Future<void> initialize({required String appId}) async {
    if (_initialized) return;

    _engine = createAgoraRtcEngine();

    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );

    _engine!.registerEventHandler(
      RtcEngineEventHandler(
        onError: (err, msg) {
          debugPrint("🚨 Agora error: code=$err, msg=$msg");
        },
        onJoinChannelSuccess: (connection, elapsed) {
          _joined = true;
          debugPrint("✅ Joined channel: ${connection.channelId}");
        },
        onLeaveChannel: (connection, stats) {
          _joined = false;
          debugPrint("👋 Left channel: ${connection.channelId}");
        },
        onConnectionStateChanged: (connection, state, reason) {
          debugPrint(
            "🔌 State=$state reason=$reason channel=${connection.channelId}",
          );
        },
      ),
    );

    await _engine!.enableVideo();
    _initialized = true;
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isHost,
  }) async {
    if (!_initialized) {
      throw Exception("Agora not initialized");
    }

    if (_joined) {
      debugPrint("⚠️ Already joined a channel — skipping join");
      return;
    }

    await engine.setClientRole(
      role: isHost
          ? ClientRoleType.clientRoleBroadcaster
          : ClientRoleType.clientRoleAudience,
    );

    await engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: uid, // should be 0
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    if (!_initialized || !_joined) return;
    await engine.leaveChannel();
  }

  Future<void> destroy() async {
    if (!_initialized) return;
    if (_joined) {
      await engine.leaveChannel();
    }
    await engine.release();
    _engine = null;
    _initialized = false;
    _joined = false;
  }
}
