import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'app/app_bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.ensureInitialized();

  runApp(const FinansApp());
}

class FinansApp extends StatelessWidget {
  const FinansApp({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBootstrap(
      builder: (context, localizationDelegate, router, themeProvider) {
        return AnimatedBuilder(
          animation: Listenable.merge([themeProvider, localizationDelegate]),
          builder: (context, _) {
            return MaterialApp.router(
              debugShowCheckedModeBanner: false,
              title: 'Finans Koçu',
              routerConfig: router,
              theme: themeProvider.currentTheme.light,
              darkTheme: themeProvider.currentTheme.dark,
              themeMode: themeProvider.themeMode,
              locale: localizationDelegate.currentLocale,
              supportedLocales: localizationDelegate.supportedLocales,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
            );
          },
        );
      },
    );
  }
}
