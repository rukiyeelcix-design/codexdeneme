import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../core/providers/navigation_provider.dart';
import '../core/providers/finance_provider.dart';
import '../core/providers/theme_provider.dart';
import '../features/ai/presentation/ai_fullscreen_page.dart';
import '../features/settings/presentation/settings_sheet.dart';
import 'import_review_sheet.dart';
import '../core/services/supabase_service.dart';

class ShellScaffold extends StatefulWidget {
  const ShellScaffold({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _drawerController;
  bool _drawerOpen = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _drawerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _drawerController.dispose();
    super.dispose();
  }

  void _toggleDrawer() {
    setState(() {
      _drawerOpen = !_drawerOpen;
      if (_drawerOpen) {
        _drawerController.forward();
        _scaffoldKey.currentState?.openDrawer();
      } else {
        _drawerController.reverse();
        _scaffoldKey.currentState?.closeDrawer();
      }
    });
  }

  void _openAiPopover() {
    final l10n = context.localization;
    showDialog<void>(
      context: context,
      barrierColor: Colors.black54,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.translate('ai_greeting'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _QuickActionChip(
                      label: l10n.translate('ai_action_spending'),
                    ),
                    _QuickActionChip(
                      label: l10n.translate('ai_action_upcoming'),
                    ),
                    _QuickActionChip(
                      label: l10n.translate('ai_action_budget'),
                    ),
                    _QuickActionChip(
                      label: l10n.translate('ai_action_savings'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      GoRouter.of(context).push(AiFullscreenPage.routePath);
                    },
                    child: Text(l10n.translate('ai_assistant')),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _openQuickAdd() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final l10n = context.localization;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.trending_up_rounded),
                title: Text(l10n.translate('add_income')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTransactionForm(TransactionKind.income);
                },
              ),
              ListTile(
                leading: const Icon(Icons.shopping_cart_checkout_rounded),
                title: Text(l10n.translate('add_expense')),
                onTap: () {
                  Navigator.of(context).pop();
                  _showTransactionForm(TransactionKind.expense);
                },
              ),
              ListTile(
                leading: const Icon(Icons.document_scanner_rounded),
                title: Text(l10n.translate('scan_invoice')),
                subtitle: Text(l10n.translate('ocr_placeholder')),
                onTap: () {
                  Navigator.of(context).pop();
                  _promptImportKind();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _promptImportKind() async {
    if (!mounted) return;
    final l10n = context.localization;
    final kind = await showDialog<TransactionKind?>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(l10n.translate('import_from_document')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(TransactionKind.expense),
            child: Text(l10n.translate('add_expense')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.of(context).pop(TransactionKind.income),
            child: Text(l10n.translate('add_income')),
          ),
        ],
      ),
    );
    if (kind == null || !mounted) return;
    await showImportReviewSheet(context, kind);
  }

  Future<void> _showTransactionForm(TransactionKind kind) async {
    final finance = context.read<FinanceDataProvider>();
    final l10n = context.localization;
    final formKey = GlobalKey<FormState>();
    final descriptionController = TextEditingController();
    final amountController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String? selectedAccount = finance.accounts.isNotEmpty ? finance.accounts.first.id : null;
    String? selectedMainCategory;
    String? selectedSubCategory;
    int installments = 1;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final categories = kind == TransactionKind.income
            ? finance.incomeCategories
            : finance.expenseCategories;
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: formKey,
                  child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      kind == TransactionKind.income
                        ? l10n.translate('add_income')
                        : l10n.translate('add_expense'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedAccount,
                    items: [
                      for (final account in finance.accounts)
                        DropdownMenuItem(
                          value: account.id,
                          child: Text(account.name),
                        ),
                    ],
                    onChanged: (value) => setModalState(() => selectedAccount = value),
                    decoration: InputDecoration(
                      labelText: l10n.translate('accounts_cards'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: l10n.translate('description'),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.translate('required') : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.translate('amount')),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return l10n.translate('required');
                      }
                      final parsed = double.tryParse(value.replaceAll(',', '.'));
                      if (parsed == null) {
                        return l10n.translate('invalid_number');
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event_rounded),
                    title: Text(l10n.translate('date')),
                    subtitle: Text(DateFormat.yMMMMd().format(selectedDate)),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDate: selectedDate,
                      );
                      if (picked != null) {
                        setModalState(() => selectedDate = picked);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedMainCategory,
                    decoration: InputDecoration(labelText: l10n.translate('main_category')),
                    items: [
                      for (final entry in categories.entries)
                        DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.key),
                        ),
                    ],
                    onChanged: (value) {
                      setModalState(() {
                        selectedMainCategory = value;
                        selectedSubCategory = null;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedSubCategory,
                    decoration: InputDecoration(labelText: l10n.translate('sub_category')),
                    items: [
                      if (selectedMainCategory != null)
                        for (final item in categories[selectedMainCategory] ?? const [])
                          DropdownMenuItem(value: item, child: Text(item)),
                    ],
                    onChanged: (value) => setModalState(() => selectedSubCategory = value),
                  ),
                  if (kind == TransactionKind.expense) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      initialValue: '1',
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(labelText: l10n.translate('installments')),
                      onChanged: (value) {
                        final parsed = int.tryParse(value);
                        if (parsed != null && parsed > 0) {
                          setModalState(() => installments = parsed);
                        }
                      },
                    ),
                  ],
                  const SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      icon: const Icon(Icons.save_rounded),
                      label: Text(l10n.translate('save')),
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        if (selectedAccount == null) return;
                        final amount =
                            double.parse(amountController.text.replaceAll(',', '.'));
                        await finance.addTransaction(
                          accountId: selectedAccount!,
                          kind: kind,
                          date: selectedDate,
                          description: descriptionController.text,
                          amount: amount,
                          mainCategory: selectedMainCategory,
                          subCategory: selectedSubCategory,
                          installments: installments,
                          paid: kind == TransactionKind.income,
                        );
                        if (!mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(l10n.translate('saved_successfully')),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        );
      },
    );
    descriptionController.dispose();
    amountController.dispose();
  }

  void _showReorderSheet(NavigationProvider provider) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        final destinations = provider.destinations;
        return StatefulBuilder(
          builder: (context, setState) {
            return ReorderableListView(
              shrinkWrap: true,
              onReorder: (oldIndex, newIndex) async {
                if (newIndex > oldIndex) {
                  newIndex -= 1;
                }
                await provider.reorder(oldIndex, newIndex);
                setState(() {});
              },
              children: [
                for (final destination in destinations)
                  ListTile(
                    key: ValueKey(destination.key),
                    leading: Icon(destination.icon),
                    title: Text(context.t(destination.label)),
                    trailing: const Icon(Icons.drag_indicator),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final l10n = context.localization;
    final router = GoRouter.of(context);
    final finance = context.watch<FinanceDataProvider>();
    final supabaseReady = SupabaseService.client != null;
    final lastSync = finance.lastSync;
    final lastSyncLabel = lastSync != null
        ? DateFormat.yMd(l10n.currentLocale.languageCode).add_Hm().format(lastSync)
        : l10n.translate('never');
    final planLabel = l10n.translate('plan_${finance.effectivePlan.name}');
    final statusBadges = <_StatusBadge>[
      _StatusBadge(
        icon: finance.syncEnabled ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
        label: finance.syncEnabled
            ? l10n.translate('sync_on')
            : l10n.translate('sync_off'),
        value: lastSyncLabel,
      ),
      _StatusBadge(
        icon: supabaseReady ? Icons.wifi_rounded : Icons.wifi_off_rounded,
        label: supabaseReady
            ? l10n.translate('online_mode')
            : l10n.translate('offline_mode'),
        value: supabaseReady ? 'Supabase' : '',
      ),
      _StatusBadge(
        icon: Icons.workspace_premium_rounded,
        label: l10n.translate('plan_label'),
        value: planLabel,
      ),
    ];
    if (finance.isTrialActive) {
      statusBadges.add(
        _StatusBadge(
          icon: Icons.timer_outlined,
          label: l10n.translate('trial_badge'),
          value:
              '${finance.remainingTrialDays} ${l10n.translate('days_label')}',
        ),
      );
    } else {
      statusBadges.add(
        _StatusBadge(
          icon: Icons.timer_off_outlined,
          label: l10n.translate('trial_badge'),
          value: l10n.translate('trial_expired'),
        ),
      );
    }
    if (finance.remainingFreeScans >= 0) {
      statusBadges.add(
        _StatusBadge(
          icon: Icons.document_scanner_rounded,
          label: l10n.translate('scan_remaining'),
          value: finance.remainingFreeScans.toString(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.translate('drawer_title'),
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    for (final destination in navProvider.destinations)
                      ListTile(
                        leading: Icon(destination.icon),
                        title: Text(context.t(destination.label)),
                        onTap: () {
                          router.go(destination.route);
                          Navigator.of(context).pop();
                          setState(() => _drawerOpen = false);
                          _drawerController.reverse();
                        },
                      ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings_suggest_rounded),
                      title: Text(l10n.translate('settings')),
                      onTap: () {
                        Navigator.of(context).pop();
                        router.push(SettingsSheet.routePath);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.category_rounded),
                      title: Text(l10n.translate('categories')),
                      onTap: () {
                        Navigator.of(context).pop();
                        router.push('/categories');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings),
                      title: const Text('Admin Panel'),
                      onTap: () {
                        Navigator.of(context).pop();
                        router.push('/admin');
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _toggleDrawer,
                    child: AnimatedIcon(
                      icon: AnimatedIcons.menu_arrow,
                      progress: _drawerController,
                      semanticLabel: l10n.translate('drawer_title'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(Icons.auto_awesome_rounded),
                    tooltip: l10n.translate('ai_assistant'),
                    onPressed: _openAiPopover,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.person_outline_rounded),
                    tooltip: l10n.translate('profile'),
                    onPressed: () {
                      _scaffoldKey.currentState?.openEndDrawer();
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  for (final badge in statusBadges) badge,
                ],
              ),
            ),
            Expanded(child: widget.child),
          ],
        ),
      ),
      endDrawer: _ProfileDrawer(themeProvider: themeProvider, l10n: l10n),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openQuickAdd,
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text(l10n.translate('quick_add')),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNavBar(
        onLongPress: () => _showReorderSheet(navProvider),
      ),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar({required this.onLongPress});

  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final router = GoRouter.of(context);
    final location = router.location;
    final l10n = context.localization;

    return BottomAppBar(
      notchMargin: 8,
      child: SizedBox(
        height: 72,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final destination in navProvider.destinations)
              Expanded(
                child: GestureDetector(
                  onLongPress: onLongPress,
                  onTap: () => router.go(destination.route),
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: location == destination.route ? 1 : 0.6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(destination.icon),
                        const SizedBox(height: 4),
                        Text(
                          l10n.translate(destination.label),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: textTheme.labelSmall),
              if (value.isNotEmpty)
                Text(
                  value,
                  style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileDrawer extends StatelessWidget {
  const _ProfileDrawer({
    required this.themeProvider,
    required this.l10n,
  });

  final ThemeProvider themeProvider;
  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.login_rounded),
              title: Text(l10n.translate('sign_in')),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_add_alt_1_rounded),
              title: Text(l10n.translate('sign_up')),
              onTap: () {},
            ),
            SwitchListTile(
              title: Text(l10n.translate('themes_quick_switch')),
              value: themeProvider.quickSwitchEnabled,
              onChanged: (value) => themeProvider.toggleQuickSwitch(value),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.translate('local_storage')),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionChip extends StatelessWidget {
  const _QuickActionChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: () {},
    );
  }
}
