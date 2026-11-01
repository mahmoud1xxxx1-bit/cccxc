import 'package:flutter/material.dart';

class RiftColors {
  static const background = Color(0xFF131316);
  static const surface = Color(0xFF1B1B21);
  static const raised = Color(0xFF2B2931);
  static const gold = Color(0xFFF69C52);
  static const teal = Color(0xFFF35C83);
  static const coral = Color(0xFFFF746B);
  static const text = Color(0xFFF4F7FB);
  static const muted = Color(0xFFB5B0BA);
}

ThemeData buildRiftTheme() {
  final colors = ColorScheme.fromSeed(
    seedColor: RiftColors.gold,
    brightness: Brightness.dark,
    surface: RiftColors.surface,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: RiftColors.background,
    colorScheme: colors,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: RiftColors.background,
      foregroundColor: RiftColors.text,
      elevation: 0,
      centerTitle: false,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8),
      titleLarge: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.4),
      titleMedium: TextStyle(fontWeight: FontWeight.w700),
    ),
    cardTheme: CardThemeData(
      color: RiftColors.surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        foregroundColor: RiftColors.background,
        backgroundColor: RiftColors.gold,
        minimumSize: const Size(0, 54),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.7),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: RiftColors.text,
        minimumSize: const Size(0, 52),
        side: const BorderSide(color: Color(0xFF455367)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    ),
  );
}

class RiftPanel extends StatelessWidget {
  const RiftPanel({super.key, required this.child, this.padding = const EdgeInsets.all(18)});
  final Widget child;
  final EdgeInsets padding;
  @override
  Widget build(BuildContext context) => Container(
        padding: padding,
        decoration: BoxDecoration(
          color: RiftColors.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFF273647)),
        ),
        child: child,
      );
}

class RiftButton extends StatelessWidget {
  const RiftButton({super.key, required this.text, required this.onPressed, this.icon});
  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: onPressed,
          icon: Icon(icon ?? Icons.play_arrow_rounded),
          label: Text(text),
        ),
      );
}

String formatTime(int milliseconds) {
  final hours = milliseconds ~/ 3600000;
  final minutes = (milliseconds ~/ 60000) % 60;
  final seconds = (milliseconds ~/ 1000) % 60;
  final ms = milliseconds % 1000;
  final base = '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.${ms.toString().padLeft(3, '0')}';
  return hours == 0 ? base : '${hours.toString().padLeft(2, '0')}:$base';
}
