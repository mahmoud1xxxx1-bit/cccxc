import 'dart:async';

import 'package:flame_audio/flame_audio.dart';

/// Short, original generated sounds. Limit simultaneous impacts to avoid noise.
class SoundFx {
  SoundFx(this.isEnabled);
  final bool Function() isEnabled;
  final Stopwatch _throttle = Stopwatch()..start();
  final Map<String, int> _playedAt = {};

  void play(String name, {int intervalMs = 0}) {
    if (!isEnabled()) return;
    final now = _throttle.elapsedMilliseconds;
    if (now - (_playedAt[name] ?? -1000000) < intervalMs) return;
    _playedAt[name] = now;
    unawaited(_play(name));
  }

  Future<void> _play(String name) async {
    try {
      await FlameAudio.play('$name.wav');
    } catch (_) {
      // A missing audio device must never interrupt gameplay.
    }
  }
}
