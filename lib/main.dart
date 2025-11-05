import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:user_home_page/presentation/home/home_screen.dart';
import 'package:user_home_page/theme/app_theme.dart';

/// Minimal Sizer stub used in your original project
class Sizer extends StatelessWidget {
  final Widget Function(BuildContext, Orientation, DeviceType) builder;
  const Sizer({super.key, required this.builder});

  @override
  Widget build(BuildContext context) =>
      builder(context, Orientation.portrait, DeviceType.mobile);
}

enum DeviceType { mobile, tablet }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(const MyApp());
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
          home: const HomeScreen(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', '')],
          // disable automatic font scaling (keep app consistent with design)
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: child ?? const SizedBox.shrink(),
            );
          },
        );
      },
    );
  }
}
