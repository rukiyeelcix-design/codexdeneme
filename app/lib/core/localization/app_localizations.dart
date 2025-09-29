import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocalizationDelegate extends ChangeNotifier {
  static const _assetPath = 'assets/translations';
  static const _localePrefsKey = 'app_locale_code';

  final List<Locale> supportedLocales = const [
    Locale('en'),
    Locale('tr'),
    Locale('es'),
    Locale('de'),
    Locale('fr'),
    Locale('it'),
    Locale('pt'),
    Locale('ar'),
    Locale('ru'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('hi'),
    Locale('id'),
    Locale('vi'),
  ];

  Locale _currentLocale = WidgetsBinding.instance.platformDispatcher.locale;
  Map<String, String> _translations = const {};

  Locale get currentLocale => _currentLocale;

  Future<void> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final savedCode = prefs.getString(_localePrefsKey);
    if (savedCode != null) {
      await load(Locale(savedCode));
    } else {
      await load(_currentLocale);
    }
  }

  Future<void> load(Locale locale) async {
    final asset = '$_assetPath/${locale.languageCode}.json';
    final data = await rootBundle.loadString(asset);
    final decoded = jsonDecode(data) as Map<String, dynamic>;
    _translations = decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );
    final resolved = supportedLocales.firstWhere(
      (supported) => supported.languageCode == locale.languageCode,
      orElse: () => supportedLocales.first,
    );
    _currentLocale = resolved;
    Intl.defaultLocale = _currentLocale.languageCode;
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    await load(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localePrefsKey, locale.languageCode);
  }

  String translate(String key) => _translations[key] ?? key;
}

extension LocalizationExtension on BuildContext {
  AppLocalizationDelegate get localization =>
      dependOnInheritedWidgetOfExactType<_LocalizationInherited>()!.delegate;

  String t(String key) => localization.translate(key);
}

class LocalizationProvider extends StatefulWidget {
  const LocalizationProvider({
    required this.delegate,
    required this.child,
    super.key,
  });

  final AppLocalizationDelegate delegate;
  final Widget child;

  @override
  State<LocalizationProvider> createState() => _LocalizationProviderState();
}

class _LocalizationProviderState extends State<LocalizationProvider> {
  @override
  void initState() {
    super.initState();
    widget.delegate.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.delegate,
      builder: (context, _) {
        return _LocalizationInherited(
          delegate: widget.delegate,
          child: widget.child,
        );
      },
    );
  }
}

class _LocalizationInherited extends InheritedWidget {
  const _LocalizationInherited({
    required this.delegate,
    required super.child,
  });

  final AppLocalizationDelegate delegate;

  @override
  bool updateShouldNotify(covariant _LocalizationInherited oldWidget) =>
      delegate != oldWidget.delegate;
}
