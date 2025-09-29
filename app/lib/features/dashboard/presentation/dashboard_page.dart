import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  static const routePath = '/dashboard';
  static const routeName = 'dashboard';

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    if (!finance.initialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final upcoming = finance.upcomingPayments();
    final recent = finance.recentTransactions();
    final breakdown = finance.accountSpending();

    return RefreshIndicator(
      onRefresh: () async => finance.initialize(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              Text(
                l10n.translate('dashboard'),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const Spacer(),
              const _TimeRangeBadges(),
            ],
          ),
          const SizedBox(height: 16),
          _DebtSummary(finance: finance, l10n: l10n),
          const SizedBox(height: 16),
          _QuickSummary(finance: finance, l10n: l10n),
          const SizedBox(height: 16),
          _ShortcutGrid(l10n: l10n),
          const SizedBox(height: 16),
          _UpcomingPaymentsCard(finance: finance, items: upcoming, l10n: l10n),
          const SizedBox(height: 16),
          _AccountBreakdownCard(finance: finance, breakdown: breakdown, l10n: l10n),
          const SizedBox(height: 16),
          _RecentTransactionsCard(finance: finance, transactions: recent, l10n: l10n),
        ],
      ),
    );
  }
}

class _TimeRangeBadges extends StatelessWidget {
  const _TimeRangeBadges();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final chips = [
      'months_1',
      'months_3',
      'months_9',
      'years_1',
      'years_2',
      'custom_range',
    ];
    return Wrap(
      spacing: 6,
      children: [
        for (final key in chips)
          FilterChip(
            label: Text(l10n.translate(key)),
            selected: key == 'months_3',
            onSelected: (_) {},
          ),
      ],
    );
  }
}

class _DebtSummary extends StatelessWidget {
  const _DebtSummary({required this.finance, required this.l10n});

  final FinanceDataProvider finance;
  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            title: l10n.translate('total_debt'),
            value: finance.formatCurrency(finance.outstandingDebt + finance.paidDebt),
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.translate('paid'),
            value: finance.formatCurrency(finance.paidDebt),
            color: Theme.of(context).colorScheme.secondaryContainer,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _SummaryCard(
            title: l10n.translate('pending'),
            value: finance.formatCurrency(finance.outstandingDebt),
            color: Theme.of(context).colorScheme.tertiaryContainer,
          ),
        ),
      ],
    );
  }
}

class _QuickSummary extends StatelessWidget {
  const _QuickSummary({required this.finance, required this.l10n});

  final FinanceDataProvider finance;
  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('time_filter'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                _QuickStat(
                  label: l10n.translate('income'),
                  value: finance.formatCurrency(finance.totalIncome),
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                _QuickStat(
                  label: l10n.translate('expense'),
                  value: finance.formatCurrency(finance.totalExpense),
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 12),
                _QuickStat(
                  label: 'Net',
                  value: finance.formatCurrency(finance.netBalance),
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShortcutGrid extends StatelessWidget {
  const _ShortcutGrid({required this.l10n});

  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _ShortcutChip(
              icon: Icons.trending_up_rounded,
              label: l10n.translate('income'),
              onPressed: () => router.go('/income'),
            ),
            _ShortcutChip(
              icon: Icons.shopping_bag_rounded,
              label: l10n.translate('expense'),
              onPressed: () => router.go('/expense'),
            ),
            _ShortcutChip(
              icon: Icons.document_scanner_rounded,
              label: l10n.translate('scan'),
              onPressed: () => router.go('/expense'),
            ),
            _ShortcutChip(
              icon: Icons.analytics_rounded,
              label: l10n.translate('analytics'),
              onPressed: () => router.go('/analytics'),
            ),
            _ShortcutChip(
              icon: Icons.category_rounded,
              label: l10n.translate('categories'),
              onPressed: () => router.go('/categories'),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingPaymentsCard extends StatelessWidget {
  const _UpcomingPaymentsCard({
    required this.finance,
    required this.items,
    required this.l10n,
  });

  final FinanceDataProvider finance;
  final List<TransactionRecord> items;
  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('notifications'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(l10n.translate('ocr_in_progress'))
            else
              for (final tx in items)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(tx.description),
                  subtitle: Text(
                    '${DateFormat.yMMMEd().format(tx.firstInstallment)} · ${tx.mainCategory ?? ''}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(finance.formatCurrency(tx.amount)),
                      IconButton(
                        icon: Icon(
                          tx.isPaid
                              ? Icons.check_circle_rounded
                              : Icons.radio_button_unchecked,
                          color: tx.isPaid
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outline,
                        ),
                        onPressed: () => finance.togglePaid(tx.id),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }
}

class _AccountBreakdownCard extends StatelessWidget {
  const _AccountBreakdownCard({
    required this.finance,
    required this.breakdown,
    required this.l10n,
  });

  final FinanceDataProvider finance;
  final Map<String, AccountSpending> breakdown;
  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('analytics'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final spending in breakdown.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            spending.account.name,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Text(finance.formatCurrency(spending.total)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: spending.total == 0 ? 0 : spending.paid / spending.total,
                      minHeight: 10,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${l10n.translate('paid')}: ${finance.formatCurrency(spending.paid)}'),
                        Text('${l10n.translate('pending')}: ${finance.formatCurrency(spending.pending)}'),
                      ],
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecentTransactionsCard extends StatelessWidget {
  const _RecentTransactionsCard({
    required this.finance,
    required this.transactions,
    required this.l10n,
  });

  final FinanceDataProvider finance;
  final List<TransactionRecord> transactions;
  final AppLocalizationDelegate l10n;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.translate('quick_add'),
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            for (final tx in transactions)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  tx.isIncome
                      ? Icons.trending_up_rounded
                      : Icons.shopping_bag_rounded,
                  color: tx.isIncome
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.error,
                ),
                title: Text(tx.description),
                subtitle: Text(
                  '${DateFormat.yMd().format(tx.date)} · ${tx.mainCategory ?? ''}',
                ),
                trailing: Text(finance.formatCurrency(tx.amount)),
              ),
          ],
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context)
                .textTheme
                .headlineSmall
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 8),
            Text(value, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}

class _ShortcutChip extends StatelessWidget {
  const _ShortcutChip({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      avatar: Icon(icon, size: 18),
      label: Text(label),
      onPressed: onPressed,
    );
  }
}
