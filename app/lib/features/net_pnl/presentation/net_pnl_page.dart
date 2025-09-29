import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';

class NetPnlPage extends StatefulWidget {
  const NetPnlPage({super.key});

  static const routePath = '/netpnl';
  static const routeName = 'netpnl';

  @override
  State<NetPnlPage> createState() => _NetPnlPageState();
}

class _NetPnlPageState extends State<NetPnlPage> {
  String _range = 'this_month';
  DateTimeRange? _customRange;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final range = _resolveRange();
    final incomes = finance.incomes
        .where((t) => t.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(range.end.add(const Duration(days: 1))))
        .toList();
    final expenses = finance.expenses
        .where((t) => t.date.isAfter(range.start.subtract(const Duration(days: 1))) &&
            t.date.isBefore(range.end.add(const Duration(days: 1))))
        .toList();
    final totalIncome = incomes.fold(0.0, (sum, tx) => sum + tx.amount);
    final totalExpense = expenses.fold(0.0, (sum, tx) => sum + tx.amount);
    final net = totalIncome - totalExpense;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('net_pnl'))),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                DropdownButton<String>(
                  value: _range,
                  items: [
                    DropdownMenuItem(value: 'this_month', child: Text('Bu Ay')),
                    DropdownMenuItem(value: 'last_3', child: Text('Son 3 Ay')),
                    DropdownMenuItem(value: 'ytd', child: Text('Yılbaşı - Bugün')),
                    DropdownMenuItem(value: 'custom', child: Text('Özel Aralık')),
                  ],
                  onChanged: (value) async {
                    if (value == 'custom') {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        initialDateRange: _customRange ?? _resolveRange(),
                      );
                      if (picked != null) {
                        setState(() {
                          _customRange = picked;
                          _range = 'custom';
                        });
                      }
                    } else {
                      setState(() => _range = value ?? _range);
                    }
                  },
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () => _showAiSheet(context, l10n),
                  child: Text(l10n.translate('ai_action_savings')),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${DateFormat.yMMMd().format(range.start)} - ${DateFormat.yMMMd().format(range.end)}'),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _NetTile(
                            label: l10n.translate('income'),
                            value: finance.formatCurrency(totalIncome),
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _NetTile(
                            label: l10n.translate('expense'),
                            value: finance.formatCurrency(totalExpense),
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _NetTile(
                      label: 'Net',
                      value: finance.formatCurrency(net),
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView(
                children: [
                  _TransactionGroup(
                    title: l10n.translate('income'),
                    transactions: incomes,
                    finance: finance,
                  ),
                  _TransactionGroup(
                    title: l10n.translate('expense'),
                    transactions: expenses,
                    finance: finance,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  DateTimeRange _resolveRange() {
    final now = DateTime.now();
    switch (_range) {
      case 'last_3':
        final start = DateTime(now.year, now.month - 2, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: start, end: end);
      case 'ytd':
        final start = DateTime(now.year, 1, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: start, end: end);
      case 'custom':
        return _customRange ?? DateTimeRange(start: now, end: now);
      case 'this_month':
      default:
        final start = DateTime(now.year, now.month, 1);
        final end = DateTime(now.year, now.month + 1, 0);
        return DateTimeRange(start: start, end: end);
    }
  }

  Future<void> _showAiSheet(BuildContext context, AppLocalizationDelegate l10n) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('ai_action_savings'),
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 12),
              Text('Gemini: Bütçe tasarruf planı hazırlanıyor...'),
              const SizedBox(height: 8),
              Text('Grok: Harcama kalemlerini yeniden gruplayalım mı?'),
            ],
          ),
        );
      },
    );
  }
}

class _NetTile extends StatelessWidget {
  const _NetTile({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _TransactionGroup extends StatelessWidget {
  const _TransactionGroup({
    required this.title,
    required this.transactions,
    required this.finance,
  });

  final String title;
  final List<TransactionRecord> transactions;
  final FinanceDataProvider finance;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(title),
        children: [
          for (final tx in transactions)
            ListTile(
              title: Text(tx.description),
              subtitle: Text(DateFormat.yMMMd().format(tx.date)),
              trailing: Text(finance.formatCurrency(tx.amount)),
            ),
        ],
      ),
    );
  }
}
