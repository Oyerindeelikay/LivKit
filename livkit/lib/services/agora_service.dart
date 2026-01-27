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
      uid: uid,
      options: const ChannelMediaOptions(),
    );
  }

  Future<void> leaveChannel() async {
    if (!_initialized) return;

    // ALWAYS try to leave. Idempotent.
    try {
      await engine.leaveChannel();
    } catch (e) {
      debugPrint("⚠️ leaveChannel failed: $e");
    } finally {
      _joined = false;
    }
  }

  Future<void> destroy() async {
    if (!_initialized) return;

    // Don't call leaveChannel here.
    // The UI already handles cleanup.
    try {
      await engine.release();
    } catch (e) {
      debugPrint("⚠️ destroy failed: $e");
    } finally {
      _engine = null;
      _initialized = false;
      _joined = false;
    }
  }
}
