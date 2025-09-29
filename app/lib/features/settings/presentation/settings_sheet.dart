import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/supabase_service.dart';
import '../../../widgets/plan_selector.dart';

class SettingsSheet extends StatelessWidget {
  const SettingsSheet({super.key});

  static const routePath = '/settings';
  static const routeName = 'settings';

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final syncAvailable = SupabaseService.client != null;
    final lastSync = finance.lastSync;
    final localeCode = l10n.currentLocale.languageCode;
    final lastSyncLabel = lastSync != null
        ? DateFormat.yMd(localeCode).add_Hm().format(lastSync)
        : l10n.translate('never');
    final planLabel = l10n.translate('plan_${finance.effectivePlan.name}');
    final trialStatus = finance.isTrialActive
        ? '${l10n.translate('trial_days_left')} ${finance.remainingTrialDays} ${l10n.translate('days_label')}'
        : l10n.translate('trial_expired');
    final remainingScans = finance.remainingFreeScans;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('settings'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.workspace_premium_rounded),
            title: Text(l10n.translate('membership_plans')),
            subtitle: Text(
              '${l10n.translate('current_plan')}: $planLabel\n$trialStatus',
            ),
            trailing: remainingScans >= 0
                ? Chip(
                    avatar: const Icon(Icons.document_scanner_rounded, size: 18),
                    label: Text(
                      '${l10n.translate('scan_remaining')} $remainingScans',
                    ),
                  )
                : null,
            onTap: () => showPlanSelector(context),
          ),
          const Divider(),
          Text(l10n.translate('theme'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            children: [
              for (final palette in ThemeCatalog.palettes)
                ChoiceChip(
                  selected: themeProvider.currentTheme.name == palette.name,
                  label: Text(palette.name),
                  onSelected: (_) => themeProvider.updatePalette(palette),
                ),
            ],
          ),
          const SizedBox(height: 24),
          Text(l10n.translate('dark_mode'), style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          DropdownButton<ThemeMode>(
            value: themeProvider.themeMode,
            onChanged: (value) {
              if (value != null) themeProvider.updateMode(value);
            },
            items: const [
              DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
              DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
              DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
            ],
          ),
          const SizedBox(height: 24),
          ListTile(
            leading: const Icon(Icons.language_rounded),
            title: Text(l10n.translate('language')),
            subtitle: Text(l10n.translate('language_prompt')),
            onTap: () => _showLanguageDialog(context),
          ),
          ListTile(
            leading: const Icon(Icons.currency_exchange_rounded),
            title: Text(l10n.translate('currency')),
            subtitle: Text('${l10n.translate('currency_prompt')} (${finance.defaultCurrency})'),
            onTap: () => _showCurrencyDialog(context, finance),
          ),
          SwitchListTile.adaptive(
            secondary: const Icon(Icons.cloud_sync_rounded),
            title: Text(l10n.translate('cloud_sync')),
            subtitle: Text(
              syncAvailable
                  ? '${l10n.translate('last_synced')} $lastSyncLabel'
                  : l10n.translate('sync_disabled_no_supabase'),
            ),
            value: finance.syncEnabled && syncAvailable,
            onChanged: syncAvailable
                ? (value) async => finance.setSyncEnabled(value)
                : null,
          ),
          ListTile(
            leading: const Icon(Icons.sync_rounded),
            title: Text(l10n.translate('sync_now')),
            subtitle: Text(l10n.translate('sync_now_hint')),
            onTap: !syncAvailable || !finance.syncEnabled
                ? null
                : () async {
                    await finance.syncNow();
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(l10n.translate('sync_triggered'))),
                    );
                  },
          ),
          ListTile(
            leading: const Icon(Icons.api_rounded),
            title: Text(l10n.translate('ai_add_api')),
            subtitle: const Text('Connect Gemini, Grok, or OpenAI via Supabase secrets'),
            onTap: () => _showApiDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final delegate = context.localization;
    final selected = await showDialog<Locale>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(delegate.translate('language_prompt')),
        children: [
          for (final locale in delegate.supportedLocales)
            SimpleDialogOption(
              onPressed: () => Navigator.of(context).pop(locale),
              child: Text(locale.languageCode.toUpperCase()),
            ),
        ],
      ),
    );
    if (selected != null) {
      await delegate.setLocale(selected);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(delegate.translate('language_saved'))),
        );
      }
    }
  }

  Future<void> _showCurrencyDialog(
    BuildContext context,
    FinanceDataProvider finance,
  ) async {
    final currencies = ['TRY', 'USD', 'EUR', 'GBP'];
    await showDialog<void>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(context.localization.translate('currency_prompt')),
        children: [
          for (final currency in currencies)
            SimpleDialogOption(
              onPressed: () {
                finance.changeCurrency(currency);
                Navigator.of(context).pop();
              },
              child: Text(currency),
            ),
        ],
      ),
    );
  }

  Future<void> _showApiDialog(BuildContext context) async {
    await showPlanSelector(context);
    if (!context.mounted) return;
    final controller = TextEditingController();
    await showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.localization.translate('ai_add_api')),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'API Key'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(context.localization.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    controller.dispose();
  }
}
