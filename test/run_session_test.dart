import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_rift/game/run_session.dart';

void main() {
  test('a run completes only after 2300 individual brick destructions', () {
    final run = RunSession();
    expect(run.status, RunStatus.ready);
    expect(run.launch(), isTrue);
    for (var i=0;i<2299;i++) { run.breakPixels(1); }
    expect(run.pixelsDestroyed, 2299);
    expect(run.status, RunStatus.playing);
    run.breakPixels(1);
    expect(run.status, RunStatus.won);
    expect(run.pixelsDestroyed, 2300);
    run.dispose();
  });

  test('three complete ball losses end the run, not one', () {
    final run = RunSession();
    for (var i=0;i<3;i++) {
      expect(run.launch(), isTrue);
      run.loseAllBalls();
    }
    expect(run.losses, 3);
    expect(run.status, RunStatus.lost);
    run.dispose();
  });

  test('pausing disqualifies future online ranking', () {
    final run = RunSession();
    run.launch();
    run.pause();
    expect(run.rankedEligible, false);
    run.resume();
    expect(run.status, RunStatus.playing);
    run.dispose();
  });
}
