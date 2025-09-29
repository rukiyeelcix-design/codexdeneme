import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/localization/app_localizations.dart';
import '../core/providers/navigation_provider.dart';
import '../core/providers/finance_provider.dart';
import '../core/providers/theme_provider.dart';
import '../core/services/local_storage_service.dart';
import '../core/services/supabase_service.dart';
import '../core/theme/app_theme.dart';
import '../features/admin/presentation/admin_panel_page.dart';
import '../features/ai/presentation/ai_fullscreen_page.dart';
import '../features/analytics/presentation/analytics_page.dart';
import '../features/categories/presentation/categories_page.dart';
import '../features/dashboard/presentation/dashboard_page.dart';
import '../features/accounts/presentation/accounts_page.dart';
import '../features/expense/presentation/expense_page.dart';
import '../features/income/presentation/income_page.dart';
import '../features/net_pnl/presentation/net_pnl_page.dart';
import '../features/onboarding/presentation/onboarding_flow.dart';
import '../features/settings/presentation/settings_sheet.dart';
import '../widgets/shell_scaffold.dart';

class AppBootstrap extends StatefulWidget {
  const AppBootstrap({
    required this.builder,
    super.key,
  });

  final Widget Function(
    BuildContext context,
    AppLocalizationDelegate localizationDelegate,
    GoRouter router,
    ThemeProvider themeProvider,
  ) builder;

  static Future<void> ensureInitialized() async {
    await Hive.initFlutter();
    await LocalStorageService.ensureInitialized();
    await SupabaseService.ensureInitialized();
  }

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  late final AppLocalizationDelegate _localizationDelegate;
  late final ThemeProvider _themeProvider;
  late final NavigationProvider _navigationProvider;
  late final FinanceDataProvider _financeProvider;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _localizationDelegate = AppLocalizationDelegate();
    _themeProvider = ThemeProvider();
    _navigationProvider = NavigationProvider();
    _financeProvider = FinanceDataProvider()..initialize();

    _router = GoRouter(
      initialLocation: DashboardPage.routePath,
      routes: [
        ShellRoute(
          builder: (context, state, child) => MultiProvider(
            providers: [
              ChangeNotifierProvider.value(value: _themeProvider),
              ChangeNotifierProvider.value(value: _navigationProvider),
              ChangeNotifierProvider.value(value: _financeProvider),
            ],
            child: ShellScaffold(child: child),
          ),
          routes: [
            GoRoute(
              path: DashboardPage.routePath,
              name: DashboardPage.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: DashboardPage(),
              ),
            ),
            GoRoute(
              path: AccountsPage.routePath,
              name: AccountsPage.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AccountsPage(),
              ),
            ),
            GoRoute(
              path: IncomePage.routePath,
              name: IncomePage.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: IncomePage(),
              ),
            ),
            GoRoute(
              path: ExpensePage.routePath,
              name: ExpensePage.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: ExpensePage(),
              ),
            ),
            GoRoute(
              path: AnalyticsPage.routePath,
              name: AnalyticsPage.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: AnalyticsPage(),
              ),
            ),
            GoRoute(
              path: NetPnlPage.routePath,
              name: NetPnlPage.routeName,
              pageBuilder: (context, state) => const NoTransitionPage(
                child: NetPnlPage(),
              ),
            ),
            GoRoute(
              path: CategoriesPage.routePath,
              name: CategoriesPage.routeName,
              pageBuilder: (context, state) => const MaterialPage(
                child: CategoriesPage(),
              ),
            ),
          ],
        ),
        GoRoute(
          path: SettingsSheet.routePath,
          name: SettingsSheet.routeName,
          pageBuilder: (context, state) => const MaterialPage(
            fullscreenDialog: true,
            child: SettingsSheet(),
          ),
        ),
        GoRoute(
          path: AiFullscreenPage.routePath,
          name: AiFullscreenPage.routeName,
          pageBuilder: (context, state) => const MaterialPage(
            fullscreenDialog: true,
            child: AiFullscreenPage(),
          ),
        ),
        GoRoute(
          path: AdminPanelPage.routePath,
          name: AdminPanelPage.routeName,
          pageBuilder: (context, state) => const MaterialPage(
            child: AdminPanelPage(),
          ),
        ),
        GoRoute(
          path: OnboardingFlow.routePath,
          name: OnboardingFlow.routeName,
          pageBuilder: (context, state) => const MaterialPage(
            child: OnboardingFlow(),
          ),
        ),
      ],
      redirect: (context, state) async {
        final prefs = await SharedPreferences.getInstance();
        final finishedOnboarding =
            prefs.getBool(OnboardingFlow.finishedKey) ?? false;
        if (!finishedOnboarding && state.uri.path != OnboardingFlow.routePath) {
          return OnboardingFlow.routePath;
        }
        return null;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _themeProvider),
        Provider.value(value: _localizationDelegate),
        ChangeNotifierProvider.value(value: _navigationProvider),
        ChangeNotifierProvider.value(value: _financeProvider),
      ],
      child: LocalizationProvider(
        delegate: _localizationDelegate,
        child: widget.builder(
          context,
          _localizationDelegate,
          _router,
          _themeProvider,
        ),
      ),
    );
  }
}
