import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RiftModel extends ChangeNotifier {
  SharedPreferences? _prefs;
  int? bestTimeMs;
  int victories = 0;
  int failedRuns = 0;
  bool soundEnabled = true;
  bool reduceEffects = false;
  bool vibrationEnabled = true;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    bestTimeMs = _prefs!.getInt('desert_gate_best_ms');
    victories = _prefs!.getInt('victories') ?? 0;
    failedRuns = _prefs!.getInt('failed_runs') ?? 0;
    soundEnabled = _prefs!.getBool('sfx') ?? true;
    reduceEffects = _prefs!.getBool('reduce_effects') ?? false;
    vibrationEnabled = _prefs!.getBool('vibration') ?? true;
    notifyListeners();
  }

  Future<bool> recordVictory(int elapsedMs) async {
    final improved = bestTimeMs == null || elapsedMs < bestTimeMs!;
    victories++;
    await _prefs?.setInt('victories', victories);
    if (improved) {
      bestTimeMs = elapsedMs;
      await _prefs?.setInt('desert_gate_best_ms', elapsedMs);
    }
    notifyListeners();
    return improved;
  }

  Future<void> recordFailure() async {
    failedRuns++;
    await _prefs?.setInt('failed_runs', failedRuns);
    notifyListeners();
  }

  Future<void> setSound(bool v) async {
    soundEnabled = v;
    await _prefs?.setBool('sfx', v);
    notifyListeners();
  }

  Future<void> setReduceEffects(bool v) async {
    reduceEffects = v;
    await _prefs?.setBool('reduce_effects', v);
    notifyListeners();
  }

  Future<void> setVibration(bool v) async {
    vibrationEnabled = v;
    await _prefs?.setBool('vibration', v);
    notifyListeners();
  }
}
