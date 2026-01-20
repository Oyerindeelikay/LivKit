// lib/services/agora_service.dart
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
class AgoraService {
  RtcEngine? _engine;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  RtcEngine get engine {
    if (_engine == null || !_initialized) {
      throw Exception("Agora engine not initialized");
    }
    return _engine!;
  }

  Future<void> initialize({required String appId}) async {
    _engine = createAgoraRtcEngine();
    await _engine!.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile:
            ChannelProfileType.channelProfileLiveBroadcasting,
      ),
    );
    await _engine!.enableVideo();
    _initialized = true;
  }

  Future<void> leaveChannel() async {
    if (!_initialized) return;
    await _engine?.leaveChannel();
  }

  Future<void> destroy() async {
    if (!_initialized) return;
    await _engine?.release();
    _engine = null;
    _initialized = false;
  }

  Future<void> joinChannel({
    required String token,
    required String channelName,
    required int uid,
    required bool isHost,
  }) async {
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
}
