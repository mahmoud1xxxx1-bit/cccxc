import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'ui/pages.dart';
import 'ui/rift_model.dart';
import 'ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: RiftColors.background,
    systemNavigationBarIconBrightness: Brightness.light,
  ));
  final model = RiftModel();
  await model.load();
  runApp(PixelRiftApp(model: model));
}

class PixelRiftApp extends StatelessWidget {
  const PixelRiftApp({super.key, required this.model});
  final RiftModel model;

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'PIXEL RIFT',
        theme: buildRiftTheme(),
        debugShowCheckedModeBanner: false,
        home: HomeShell(model: model),
      );
}
