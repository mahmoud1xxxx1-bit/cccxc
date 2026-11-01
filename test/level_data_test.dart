import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_rift/game/level_data.dart';

void main() {
  test('Desert Gate has exactly 2300 destroyable cells, 260 paths, 140 walls', () {
    expect(DesertGateLevel.map.length, 45);
    expect(DesertGateLevel.map.every((row) => row.length == 60), isTrue);
    final chars = DesertGateLevel.map.join();
    final bricks = 'BGP'.split('').fold(0, (sum, c) => sum + c.allMatches(chars).length);
    expect(bricks, 2300);
    expect('#'.allMatches(chars).length, 140);
    expect('.'.allMatches(chars).length, 260);
    expect('P'.allMatches(chars).length, 12);
  });
}
