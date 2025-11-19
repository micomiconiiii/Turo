import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:device_preview/device_preview.dart';
import 'package:user_home_page/presentation/home/mentor_home_screen.dart';
import 'package:user_home_page/theme/app_theme.dart';

/// Minimal Sizer stub (from your project)
class Sizer extends StatelessWidget {
  final Widget Function(BuildContext, Orientation, DeviceType) builder;
  const Sizer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      builder(context, Orientation.portrait, DeviceType.mobile);
}

enum DeviceType { mobile, tablet }

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait only
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Enable DevicePreview only in debug mode
  runApp(
    DevicePreview(
      enabled: !const bool.fromEnvironment('dart.vm.product'),
      builder: (context) => const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return MaterialApp(
          title: 'Turo Professional',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.themeData,

          // DevicePreview setup
          locale: DevicePreview.locale(context),
          builder: (context, child) {
            return DevicePreview.appBuilder(
              context,
              MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  // ✅ replaced textScaleFactor with textScaler
                  textScaler: const TextScaler.linear(1.0),
                ),
                child: child ?? const SizedBox.shrink(),
              ),
            );
          },

          home: const HomeScreen(),

          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
        );
      },
    );
  }
}
