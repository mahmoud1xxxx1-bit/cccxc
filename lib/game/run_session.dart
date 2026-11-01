import 'package:flutter/foundation.dart';
import 'level_data.dart';

enum RunStatus { ready, playing, paused, won, lost }

/// Local run timing; not verified for public leaderboards.
class RunSession extends ChangeNotifier {
  final Stopwatch _clock = Stopwatch();
  RunStatus status = RunStatus.ready;
  RunStatus _statusBeforePause = RunStatus.ready;
  int pixelsDestroyed = 0;
  int losses = 0;
  bool rankedEligible = true;
  int _lastDisplayTime = -1;

  int get elapsedMs => _clock.elapsedMicroseconds ~/ 1000;
  int get remaining => DesertGateLevel.totalPixels - pixelsDestroyed;
  double get progress => pixelsDestroyed / DesertGateLevel.totalPixels;

  bool launch() {
    if (status != RunStatus.ready) return false;
    status = RunStatus.playing;
    if (!_clock.isRunning) _clock.start();
    notifyListeners();
    return true;
  }

  void breakPixels(int count) {
    if (status != RunStatus.playing || count <= 0) return;
    pixelsDestroyed += count;
    if (pixelsDestroyed > DesertGateLevel.totalPixels) {
      throw StateError('Pixel counter exceeded level capacity');
    }
    if (pixelsDestroyed == DesertGateLevel.totalPixels) {
      _clock.stop();
      status = RunStatus.won;
    }
    notifyListeners();
  }

  void loseAllBalls() {
    if (status != RunStatus.playing) return;
    losses++;
    if (losses >= 3) {
      _clock.stop();
      status = RunStatus.lost;
    } else {
      // Stopwatch intentionally continues between volleys.
      status = RunStatus.ready;
    }
    notifyListeners();
  }

  void pause() {
    if (status != RunStatus.ready && status != RunStatus.playing) return;
    _statusBeforePause = status;
    status = RunStatus.paused;
    _clock.stop();
    rankedEligible = false;
    notifyListeners();
  }

  void resume() {
    if (status != RunStatus.paused) return;
    status = _statusBeforePause;
    if (status == RunStatus.playing || losses > 0) _clock.start();
    notifyListeners();
  }

  /// Throttle HUD rebuilds; authoritative collision counters are never throttled.
  void refreshClock() {
    if (status != RunStatus.playing && !(status == RunStatus.ready && losses > 0)) return;
    final displayTime = elapsedMs ~/ 50;
    if (_lastDisplayTime == displayTime) return;
    _lastDisplayTime = displayTime;
    notifyListeners();
  }

  @override
  void dispose() {
    _clock.stop();
    super.dispose();
  }
}
