import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'level_data.dart';
import 'run_session.dart';
import 'sound_fx.dart';

class _Ball {
  _Ball(this.x, this.y, this.vx, this.vy);
  double x, y, vx, vy;
}

class _Pickup {
  _Pickup(this.x, this.y);
  double x, y;
}

/// Flame-driven, tile-grid arcade game. Screen positions are in logical units.
/// The two axis sweeps use small fixed substeps to prevent obvious tunneling.
class PixelRiftGame extends Game {
  PixelRiftGame({required this.session, required this.sound, required this.reduceEffects}) {
    _cells = DesertGateLevel.map.map((row) => row.split('').map((c) {
      switch (c) {
        case 'B': return 1;
        case 'G': return 2;
        case '#': return 3;
        case 'P': return 4;
        default: return 0;
      }
    }).toList()).toList();
    _balls.add(_Ball(30, paddleY - 1.1, 0, 0));
  }

  final RunSession session;
  final SoundFx sound;
  final bool reduceEffects;
  late final List<List<int>> _cells;
  final List<_Ball> _balls = [];
  final List<_Pickup> _pickups = [];
  ui.Picture? _cachedMap;
  bool _mapDirty = true;
  double _accumulator = 0;
  double paddleX = 30;
  static const double worldWidth = 60;
  static const double worldHeight = 72;
  static const double mapY = 1.3;
  static const double paddleY = 65.7;
  static const double paddleHalfWidth = 5.2;
  static const double ballRadius = 0.37;
  static const int maxActiveBalls = 300;
  int get activeBallCount => _balls.length;
  int _pendingBroken = 0;
  int _cracked = 0;
  int _nextBonus = 90;
  static const double _step = 1 / 120;

  void movePaddle(double screenX) {
    if (session.status == RunStatus.paused ||
        session.status == RunStatus.won ||
        session.status == RunStatus.lost) {
      return;
    }
    final scale = math.min(size.x / worldWidth, size.y / worldHeight);
    if (scale <= 0) { return; }
    final offset = (size.x - worldWidth * scale) / 2;
    paddleX = ((screenX - offset) / scale).clamp(paddleHalfWidth + 0.3, worldWidth - paddleHalfWidth - 0.3).toDouble();
    if (session.status == RunStatus.ready && _balls.isNotEmpty) {
      _balls.first.x = paddleX;
    }
  }

  void launch() {
    if (!session.launch()) return;
    if (_balls.isEmpty) _balls.add(_Ball(paddleX, paddleY - 1.1, 0, 0));
    final ball = _balls.first;
    ball.x = paddleX;
    ball.y = paddleY - 1.1;
    ball.vx = 10.5;
    ball.vy = -52;
    sound.play('launch');
  }

  @override
  void update(double dt) {
    if (session.status == RunStatus.ready) {
      if (_balls.isNotEmpty) _balls.first.x = paddleX;
      session.refreshClock();
      return;
    }
    if (session.status != RunStatus.playing) return;
    _accumulator += dt.clamp(0.0, 0.07);
    var cycles = 0;
    while (_accumulator >= _step && cycles < 9 && session.status == RunStatus.playing) {
      _advance(_step);
      _accumulator -= _step;
      cycles++;
    }
    if (cycles >= 9) _accumulator = 0;
    session.refreshClock();
  }

  void _advance(double dt) {
    for (final pickup in List<_Pickup>.of(_pickups)) {
      pickup.y += 23 * dt;
      if (pickup.y >= paddleY - 0.8 &&
          pickup.y <= paddleY + 1.0 &&
          (pickup.x - paddleX).abs() < paddleHalfWidth + 0.6) {
        _pickups.remove(pickup);
        collectMultiball();
      } else if (pickup.y > worldHeight) {
        _pickups.remove(pickup);
      }
    }

    _pendingBroken = 0;
    for (final b in List<_Ball>.of(_balls)) {
      if (session.status != RunStatus.playing) return;
      final travel = math.sqrt(b.vx * b.vx + b.vy * b.vy) * dt;
      final subSteps = math.max(1, (travel / 0.25).ceil());
      final subDt = dt / subSteps;
      for (var i = 0; i < subSteps; i++) {
        if (session.status != RunStatus.playing) return;
        _moveAxis(b, subDt, horizontal: true);
        _moveAxis(b, subDt, horizontal: false);
        if (b.y > worldHeight + 1) break;
      }
      if (b.y > worldHeight + 1) _balls.remove(b);
    }

    if (_pendingBroken > 0 && session.status == RunStatus.playing) {
      _cracked += _pendingBroken;
      session.breakPixels(_pendingBroken);
      sound.play('pixel', intervalMs: 25);
      if (_cracked >= _nextBonus && session.status == RunStatus.playing) {
        _pickups.add(_Pickup(paddleX, mapY + 43));
        _nextBonus += math.max(110, 215 - _cracked ~/ 15);
      }
      if (session.status == RunStatus.won) sound.play('victory');
    }
    if (_balls.isEmpty && session.status == RunStatus.playing) {
      session.loseAllBalls();
      sound.play('lost');
      if (session.status == RunStatus.ready) {
        _balls.add(_Ball(paddleX, paddleY - 1.1, 0, 0));
      }
    }
  }

  /// Collecting x3 multiplies ALL active balls until a 300-ball cap.
  /// 1 -> 3 -> 9 -> 27 -> 81 -> 243. Additional pickups fill to 300.
  void collectMultiball() {
    if (session.status != RunStatus.playing || _balls.isEmpty) return;
    for (final b in List<_Ball>.of(_balls)) {
      for (final angle in const [-0.23, 0.23]) {
        if (_balls.length >= maxActiveBalls) break;
        final ca = math.cos(angle), sa = math.sin(angle);
        _balls.add(_Ball(b.x, b.y,
            b.vx * ca - b.vy * sa, b.vx * sa + b.vy * ca));
      }
      if (_balls.length >= maxActiveBalls) break;
    }
    sound.play('powerup', intervalMs: 110);
  }

  void _moveAxis(_Ball b, double dt, {required bool horizontal}) {
    final x = horizontal ? b.x + b.vx * dt : b.x;
    final y = horizontal ? b.y : b.y + b.vy * dt;
    if (horizontal && (x < ballRadius || x > worldWidth - ballRadius)) {
      b.vx = -b.vx;
      b.x = x.clamp(ballRadius, worldWidth - ballRadius).toDouble();
      sound.play('wall', intervalMs: 85);
      return;
    }
    if (!horizontal && y < ballRadius) {
      b.vy = b.vy.abs();
      b.y = ballRadius;
      sound.play('wall', intervalMs: 85);
      return;
    }
    if (!horizontal && b.vy > 0 &&
        b.y + ballRadius <= paddleY + 0.24 &&
        y + ballRadius >= paddleY - 0.08 &&
        (x - paddleX).abs() <= paddleHalfWidth + ballRadius) {
      b.y = paddleY - ballRadius - 0.1;
      final normalized = ((x - paddleX) / paddleHalfWidth).clamp(-1.0, 1.0).toDouble();
      final speed = math.sqrt(b.vx * b.vx + b.vy * b.vy).clamp(48.0, 70.0).toDouble();
      b.vx = speed * math.sin(normalized * 1.05) + (normalized.abs() < .10 ? 2.1 : 0);
      b.vy = -math.sqrt(math.max(100, speed * speed - b.vx * b.vx));
      sound.play('paddle', intervalMs: 45);
      return;
    }
    final hits = _collidingCells(x, y);
    if (hits.isNotEmpty) {
      var metal = false;
      for (final cell in hits) {
        final col = cell.$1, row = cell.$2;
        final type = _cells[row][col];
        if (type == 3) {
          metal = true;
        } else if (type != 0) {
          _cells[row][col] = 0;
          _mapDirty = true;
          if (type == 4) _pickups.add(_Pickup(col + 0.5, mapY + row + 0.5));
          _pendingBroken++;
        }
      }
      if (horizontal) {
        b.vx = -b.vx;
      } else {
        b.vy = -b.vy;
      }
      sound.play(metal ? 'wall' : 'pixel', intervalMs: metal ? 65 : 26);
      return;
    }
    if (horizontal) {
      b.x = x;
    } else {
      b.y = y;
    }
  }

  List<(int, int)> _collidingCells(double x, double y) {
    final result = <(int, int)>[];
    final left = (x - ballRadius).floor().clamp(0, DesertGateLevel.columns - 1).toInt();
    final right = (x + ballRadius).floor().clamp(0, DesertGateLevel.columns - 1).toInt();
    final top = (y - mapY - ballRadius).floor().clamp(0, DesertGateLevel.rows - 1).toInt();
    final bottom = (y - mapY + ballRadius).floor().clamp(0, DesertGateLevel.rows - 1).toInt();
    if (y + ballRadius < mapY || y - ballRadius > mapY + DesertGateLevel.rows) return result;
    for (var row = top; row <= bottom; row++) {
      for (var col = left; col <= right; col++) {
        if (_cells[row][col] == 0) continue;
        final nearX = x.clamp(col.toDouble(), col + 1.0);
        final nearY = y.clamp(mapY + row, mapY + row + 1.0);
        final dx = x - nearX, dy = y - nearY;
        if (dx * dx + dy * dy < ballRadius * ballRadius) result.add((col, row));
      }
    }
    return result;
  }

  void _rebuildMap() {
    _cachedMap?.dispose();
    final recorder = ui.PictureRecorder();
    final c = Canvas(recorder);
    final paint = Paint();
    for (var y = 0; y < DesertGateLevel.rows; y++) {
      for (var x = 0; x < DesertGateLevel.columns; x++) {
        final tile = _cells[y][x];
        if (tile == 0) continue;
        if (tile == 3) {
          paint.color = const Color(0xFF858486);
        } else if (tile == 2) {
          paint.color = const Color(0xFFFDA14B);
        } else if (tile == 4) {
          paint.color = const Color(0xFFFFC94C);
        } else {
          final shade = (x * 3 + y * 5) % 5;
          paint.color = [
            const Color(0xFFDE6D24), const Color(0xFFE77529),
            const Color(0xFFDA671E), const Color(0xFFE27229),
            const Color(0xFFD96721),
          ][shade];
        }
        c.drawRect(Rect.fromLTWH(x + 0.065, mapY + y + 0.065, 0.87, 0.87), paint);
      }
    }
    _cachedMap = recorder.endRecording();
    _mapDirty = false;
  }

  @override
  void render(Canvas canvas) {
    final scale = math.min(size.x / worldWidth, size.y / worldHeight);
    if (scale <= 0) return;
    canvas.save();
    canvas.translate((size.x - worldWidth * scale) / 2,
        (size.y - worldHeight * scale) / 2);
    canvas.scale(scale);
    canvas.drawRect(const Rect.fromLTWH(0, 0, worldWidth, worldHeight),
        Paint()..color = const Color(0xFF171719));
    canvas.drawRRect(
      RRect.fromRectAndRadius(const Rect.fromLTWH(0, 1.5, 60, 45.9), const Radius.circular(0.4)),
      Paint()..color = const Color(0xFF171719),
    );
    if (_mapDirty || _cachedMap == null) _rebuildMap();
    canvas.drawPicture(_cachedMap!);
    canvas.drawRect(const Rect.fromLTWH(0, 47.2, 60, 0.65),
        Paint()..color = const Color(0xFF6F6C6E));
    // Subtle kicker accents (all gameplay state remains in logical coordinates).
    canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromLTWH(paddleX - paddleHalfWidth, paddleY,
            paddleHalfWidth * 2, 1.2), const Radius.circular(0.55)),
        Paint()..color = const Color(0xFFF35C83));
    for (final ball in _balls) {
      if (!reduceEffects && session.status == RunStatus.playing) {
        canvas.drawCircle(Offset(ball.x - ball.vx * 0.018, ball.y - ball.vy * 0.018),
            0.65, Paint()..color = const Color(0x44FFFFFF));
      }
      canvas.drawCircle(Offset(ball.x, ball.y), ballRadius,
          Paint()..color = const Color(0xFFFAFBFC));
    }
    for (final p in _pickups) {
      canvas.drawCircle(Offset(p.x, p.y), 1.5,
          Paint()..color = const Color(0xFFB9E34D));
      final t = ui.ParagraphBuilder(ui.ParagraphStyle(textAlign: TextAlign.center, fontSize: 2.1))
        ..pushStyle(ui.TextStyle(color: const Color(0xFF0C1119), fontWeight: ui.FontWeight.bold))
        ..addText('x3');
      final paragraph = t.build()..layout(const ui.ParagraphConstraints(width: 6));
      canvas.drawParagraph(paragraph, Offset(p.x - 3, p.y - 1.3));
    }
    canvas.restore();
  }

  @override
  void onDispose() {
    _cachedMap?.dispose();
    _cachedMap = null;
    super.onDispose();
  }
}
