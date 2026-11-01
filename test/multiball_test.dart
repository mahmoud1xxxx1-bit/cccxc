import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_rift/game/pixel_game.dart';
import 'package:pixel_rift/game/run_session.dart';
import 'package:pixel_rift/game/sound_fx.dart';

void main() {
  test('x3 multiball grows the whole swarm up to its safety cap', () {
    final session = RunSession();
    final game = PixelRiftGame(session: session,
        sound: SoundFx(() => false), reduceEffects: true);
    game.launch();
    expect(game.activeBallCount, 1);
    game.collectMultiball(); expect(game.activeBallCount, 3);
    game.collectMultiball(); expect(game.activeBallCount, 9);
    game.collectMultiball(); expect(game.activeBallCount, 27);
    for (var i = 0; i < 5; i++) { game.collectMultiball(); }
    expect(game.activeBallCount, PixelRiftGame.maxActiveBalls);
    session.dispose();
  });
}
