import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../widgets/plan_selector.dart';

class AnalyticsPage extends StatefulWidget {
  const AnalyticsPage({super.key});

  static const routePath = '/analytics';
  static const routeName = 'analytics';

  @override
  State<AnalyticsPage> createState() => _AnalyticsPageState();
}

class _AnalyticsPageState extends State<AnalyticsPage> {
  String _chartType = 'Pie';
  bool _includePaid = true;
  bool _includePending = true;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final breakdown = finance.accountSpending(
      includePaid: _includePaid,
      includePending: _includePending,
    );
    final topCategories = finance.topExpenseCategories();
    final monthly = _monthlySummary(finance);
    final categoryRows = [
      for (final entry in topCategories)
        [entry.key, finance.formatCurrency(entry.value)],
    ];
    final dailyWeeklyRows = _dailyWeeklyRows(finance, l10n);
    final budgetRows = _budgetRows(finance, l10n);
    final habitRows = _habitRows(finance, l10n);
    final debtRows = _debtRows(finance, l10n);
    final yearlyRows = _yearlyRows(finance, monthly);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('analytics'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              DropdownButton<String>(
                value: _chartType,
                onChanged: (value) => setState(() => _chartType = value ?? _chartType),
                items: const [
                  DropdownMenuItem(value: 'Pie', child: Text('Pie')),
                  DropdownMenuItem(value: 'Column', child: Text('Column')),
                  DropdownMenuItem(value: 'Line', child: Text('Line')),
                  DropdownMenuItem(value: 'Area', child: Text('Area')),
                  DropdownMenuItem(value: 'Stacked', child: Text('Stacked')),
                ],
              ),
              const Spacer(),
              FilterChip(
                label: Text(l10n.translate('paid')),
                selected: _includePaid,
                onSelected: (value) => setState(() => _includePaid = value),
              ),
              const SizedBox(width: 8),
              FilterChip(
                label: Text(l10n.translate('pending')),
                selected: _includePending,
                onSelected: (value) => setState(() => _includePending = value),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _AccountChartPlaceholder(breakdown: breakdown.values.toList()),
          const SizedBox(height: 16),
          _DualCategoryCard(topCategories: topCategories, finance: finance),
          const SizedBox(height: 16),
          _AnalyticsTable(
            title: l10n.translate('time_filter'),
            headers: [
              l10n.translate('month'),
              l10n.translate('income'),
              l10n.translate('expense'),
              l10n.translate('net'),
            ],
            rows: [
              for (final entry in monthly)
                [
                  DateFormat.yMMM().format(entry.month),
                  finance.formatCurrency(entry.income),
                  finance.formatCurrency(entry.expense),
                  finance.formatCurrency(entry.income - entry.expense),
                ],
            ],
          ),
          if (finance.canAccessStandardAnalytics)
            _AnalyticsTable(
              title: l10n.translate('category_spending_table'),
              headers: [
                l10n.translate('category'),
                l10n.translate('total'),
              ],
              rows: categoryRows,
            )
          else
            _LockedAnalyticsCard(
              title: l10n.translate('category_spending_table'),
              description: l10n.translate('analysis_locked_standard'),
            ),
          if (finance.canAccessStandardAnalytics)
            _AnalyticsTable(
              title: l10n.translate('daily_weekly_table'),
              headers: [
                l10n.translate('metric'),
                l10n.translate('amount'),
              ],
              rows: dailyWeeklyRows,
            )
          else
            _LockedAnalyticsCard(
              title: l10n.translate('daily_weekly_table'),
              description: l10n.translate('analysis_locked_standard'),
            ),
          _AnalyticsTable(
            title: l10n.translate('budget_tracking'),
            headers: [
              l10n.translate('metric'),
              l10n.translate('value'),
            ],
            rows: budgetRows,
          ),
          if (finance.canAccessPremiumAnalytics)
            _AnalyticsTable(
              title: l10n.translate('spending_habits'),
              headers: [
                l10n.translate('metric'),
                l10n.translate('detail'),
              ],
              rows: habitRows,
            )
          else
            _LockedAnalyticsCard(
              title: l10n.translate('spending_habits'),
              description: l10n.translate('analysis_locked_premium'),
            ),
          if (finance.canAccessPremiumAnalytics)
            _AnalyticsTable(
              title: l10n.translate('debt_tracking'),
              headers: [
                l10n.translate('item'),
                l10n.translate('due_date'),
                l10n.translate('status'),
              ],
              rows: debtRows,
            )
          else
            _LockedAnalyticsCard(
              title: l10n.translate('debt_tracking'),
              description: l10n.translate('analysis_locked_premium'),
            ),
          if (finance.canAccessPremiumAnalytics)
            _AnalyticsTable(
              title: l10n.translate('yearly_report'),
              headers: [
                l10n.translate('month'),
                l10n.translate('income'),
                l10n.translate('expense'),
                l10n.translate('net'),
              ],
              rows: yearlyRows,
            )
          else
            _LockedAnalyticsCard(
              title: l10n.translate('yearly_report'),
              description: l10n.translate('analysis_locked_premium'),
            ),
        ],
      ),
    );
  }

  List<_MonthlyEntry> _monthlySummary(FinanceDataProvider finance) {
    final Map<DateTime, _MonthlyEntry> entries = {};
    for (final tx in finance.incomes) {
      final month = DateTime(tx.date.year, tx.date.month);
      entries.putIfAbsent(month, () => _MonthlyEntry(month)).income += tx.amount;
    }
    for (final tx in finance.expenses) {
      final month = DateTime(tx.date.year, tx.date.month);
      entries.putIfAbsent(month, () => _MonthlyEntry(month)).expense += tx.amount;
    }
    final list = entries.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));
    return list.reversed.toList();
  }

  List<List<String>> _dailyWeeklyRows(
    FinanceDataProvider finance,
    AppLocalizationDelegate l10n,
  ) {
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 6));
    final Map<DateTime, double> totals = {};
    for (final expense in finance.expenses) {
      final day = DateTime(expense.date.year, expense.date.month, expense.date.day);
      if (day.isBefore(start)) continue;
      totals.update(day, (value) => value + expense.amount, ifAbsent: () => expense.amount);
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    double weeklyTotal = 0;
    DateTime? maxDay;
    double maxAmount = 0;
    final rows = <List<String>>[];
    for (final entry in sorted) {
      final formatted = DateFormat.MMMd(l10n.currentLocale.languageCode).format(entry.key);
      rows.add([formatted, finance.formatCurrency(entry.value)]);
      weeklyTotal += entry.value;
      if (entry.value > maxAmount) {
        maxAmount = entry.value;
        maxDay = entry.key;
      }
    }
    final average = totals.isEmpty ? 0 : weeklyTotal / totals.length;
    rows.add([l10n.translate('weekly_total'), finance.formatCurrency(weeklyTotal)]);
    rows.add([l10n.translate('daily_average'), finance.formatCurrency(average)]);
    rows.add([
      l10n.translate('top_spend_day'),
      maxDay != null
          ? DateFormat.MMMd(l10n.currentLocale.languageCode).format(maxDay!)
          : '-',
    ]);
    return rows;
  }

  List<List<String>> _budgetRows(
    FinanceDataProvider finance,
    AppLocalizationDelegate l10n,
  ) {
    final now = DateTime.now();
    final monthIncome = finance.incomes
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final monthExpense = finance.expenses
        .where((tx) => tx.date.year == now.year && tx.date.month == now.month)
        .fold<double>(0, (sum, tx) => sum + tx.amount);
    final budget = monthIncome > 0 ? monthIncome * 0.6 : 10000;
    final remaining = budget - monthExpense;
    final overBudget = remaining < 0;
    return [
      [l10n.translate('budget_target'), finance.formatCurrency(budget)],
      [l10n.translate('budget_spent'), finance.formatCurrency(monthExpense)],
      [l10n.translate('budget_remaining'), finance.formatCurrency(remaining.abs())],
      [
        l10n.translate('budget_status'),
        overBudget ? l10n.translate('over_budget') : l10n.translate('on_track'),
      ],
    ];
  }

  List<List<String>> _habitRows(
    FinanceDataProvider finance,
    AppLocalizationDelegate l10n,
  ) {
    if (finance.expenses.isEmpty) {
      return [[l10n.translate('no_data'), '-']];
    }
    final Map<String, int> counts = {};
    final Map<String, double> totals = {};
    for (final tx in finance.expenses) {
      final key = tx.mainCategory ?? l10n.translate('uncategorized');
      counts.update(key, (value) => value + 1, ifAbsent: () => 1);
      totals.update(key, (value) => value + tx.amount, ifAbsent: () => tx.amount);
    }
    if (counts.isEmpty) {
      return [[l10n.translate('no_data'), '-']];
    }
    String topCategory = counts.entries.first.key;
    int topCount = 0;
    for (final entry in counts.entries) {
      if (entry.value > topCount) {
        topCount = entry.value;
        topCategory = entry.key;
      }
    }
    final highest = finance.expenses.reduce((a, b) => a.amount > b.amount ? a : b);
    final average = finance.totalExpense / finance.expenses.length;
    return [
      [l10n.translate('habit_top_category'), '$topCategory ($topCount)'],
      [
        l10n.translate('habit_biggest_purchase'),
        '${highest.description} · ${finance.formatCurrency(highest.amount)}',
      ],
      [l10n.translate('habit_average_spend'), finance.formatCurrency(average)],
    ];
  }

  List<List<String>> _debtRows(
    FinanceDataProvider finance,
    AppLocalizationDelegate l10n,
  ) {
    if (finance.unpaidExpenses.isEmpty) {
      return [[l10n.translate('no_data'), '-', '-']];
    }
    final rows = <List<String>>[];
    for (final tx in finance.unpaidExpenses.take(8)) {
      final account = finance.accounts.firstWhere(
        (acc) => acc.id == tx.accountId,
        orElse: () => finance.accounts.isNotEmpty
            ? finance.accounts.first
            : FinanceAccount(
                id: 'temp',
                name: tx.accountId ?? 'Account',
                type: 'Bank',
                currency: finance.defaultCurrency,
              ),
      );
      final dueDay = account.dueDay ?? 1;
      final dueDate = DateTime(tx.statementYear, tx.statementMonth, dueDay);
      rows.add([
        tx.description,
        DateFormat.yMMMd(l10n.currentLocale.languageCode).format(dueDate),
        l10n.translate('pending'),
      ]);
    }
    return rows;
  }

  List<List<String>> _yearlyRows(
    FinanceDataProvider finance,
    List<_MonthlyEntry> monthly,
  ) {
    final recent = monthly.take(12).toList();
    return [
      for (final entry in recent)
        [
          DateFormat.yMMM().format(entry.month),
          finance.formatCurrency(entry.income),
          finance.formatCurrency(entry.expense),
          finance.formatCurrency(entry.income - entry.expense),
        ],
    ];
  }
}

class _AccountChartPlaceholder extends StatelessWidget {
  const _AccountChartPlaceholder({required this.breakdown});

  final List<AccountSpending> breakdown;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('account_spending_header'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            for (final entry in breakdown)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(entry.account.name)),
                        Text(
                          NumberFormat.simpleCurrency(
                            name: entry.account.currency,
                          ).format(entry.total),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    LinearProgressIndicator(
                      value: entry.total == 0 ? 0 : entry.paid / entry.total,
                      minHeight: 8,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${l10n.translate('paid')}: '
                      '${NumberFormat.simpleCurrency(name: entry.account.currency).format(entry.paid)} · '
                      '${l10n.translate('pending')}: '
                      '${NumberFormat.simpleCurrency(name: entry.account.currency).format(entry.pending)}',
                      style: Theme.of(context).textTheme.bodySmall,
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

class _DualCategoryCard extends StatelessWidget {
  const _DualCategoryCard({
    required this.topCategories,
    required this.finance,
  });

  final List<MapEntry<String, double>> topCategories;
  final FinanceDataProvider finance;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('dual_category_header'),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final entry in topCategories)
                  Chip(
                    label: Text('${entry.key}: ${finance.formatCurrency(entry.value)}'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LockedAnalyticsCard extends StatelessWidget {
  const _LockedAnalyticsCard({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lock_outline_rounded),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => showPlanSelector(context),
                child: Text(l10n.translate('upgrade_plan')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalyticsTable extends StatelessWidget {
  const _AnalyticsTable({
    required this.title,
    required this.headers,
    required this.rows,
  });

  final String title;
  final List<String> headers;
  final List<List<String>> rows;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Table(
              border: TableBorder.all(color: Theme.of(context).dividerColor),
              columnWidths: {
                for (var i = 0; i < headers.length; i++) i: const IntrinsicColumnWidth(),
              },
              children: [
                TableRow(
                  children: [
                    for (final header in headers)
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(header, style: Theme.of(context).textTheme.labelLarge),
                      ),
                  ],
                ),
                for (final row in rows)
                  TableRow(
                    children: [
                      for (final cell in row)
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Text(cell),
                        ),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthlyEntry {
  _MonthlyEntry(this.month);

  final DateTime month;
  double income = 0;
  double expense = 0;
}
