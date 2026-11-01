import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pixel_rift/ui/pages.dart';
import 'package:pixel_rift/ui/rift_model.dart';
import 'package:pixel_rift/ui/theme.dart';

void main() {
  testWidgets('Home renders playable level navigation', (tester) async {
    final model = RiftModel();
    await tester.pumpWidget(MaterialApp(
      theme: buildRiftTheme(), home: HomeShell(model: model)));
    expect(find.text('PIXEL RIFT'), findsOneWidget);
    expect(find.text('BREAK THE PATTERN.'), findsOneWidget);
    expect(find.text('DESERT GATE'), findsOneWidget);
    model.dispose();
  });
}
