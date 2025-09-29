import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  static const routePath = '/accounts';
  static const routeName = 'accounts';

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final accounts = finance.accounts;

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: accounts.length,
        itemBuilder: (context, index) {
          final account = accounts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(account.name),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${l10n.translate('currency')}: ${account.currency}'),
                  if (account.cutoffDay != null && account.dueDay != null)
                    Text('Cutoff ${account.cutoffDay} · Due ${account.dueDay}'),
                  if (account.limit != null)
                    Text('Limit: ${finance.formatCurrency(account.limit!)}'),
                ],
              ),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(finance.formatCurrency(account.balance)),
                  Text(account.type, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddAccountSheet(context, finance, l10n),
        icon: const Icon(Icons.add_circle_outline_rounded),
        label: Text(l10n.translate('add')),
      ),
    );
  }

  Future<void> _showAddAccountSheet(
    BuildContext context,
    FinanceDataProvider finance,
    AppLocalizationDelegate l10n,
  ) async {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final balanceController = TextEditingController();
    int? cutoffDay;
    int? dueDay;
    double? limit;
    String type = 'Bank Account';
    String currency = finance.defaultCurrency;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        final bottomInset = MediaQuery.of(context).viewInsets.bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: bottomInset),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(l10n.translate('accounts_cards'),
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: l10n.translate('description')),
                    validator: (value) =>
                        value == null || value.isEmpty ? l10n.translate('required') : null,
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: type,
                    items: const [
                      DropdownMenuItem(value: 'Bank Account', child: Text('Bank Account')),
                      DropdownMenuItem(value: 'Credit Card', child: Text('Credit Card')),
                      DropdownMenuItem(value: 'Cash Wallet', child: Text('Cash Wallet')),
                    ],
                    onChanged: (value) => type = value ?? type,
                    decoration: const InputDecoration(labelText: 'Type'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: currency,
                    items: ['TRY', 'USD', 'EUR']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => currency = value ?? currency,
                    decoration: InputDecoration(labelText: l10n.translate('currency')),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: balanceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(labelText: l10n.translate('amount')),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Cutoff Day'),
                    onChanged: (value) => cutoffDay = int.tryParse(value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Due Day'),
                    onChanged: (value) => dueDay = int.tryParse(value),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(labelText: 'Limit'),
                    onChanged: (value) => limit = double.tryParse(value.replaceAll(',', '.')),
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton(
                      onPressed: () async {
                        if (!(formKey.currentState?.validate() ?? false)) return;
                        final balance = double.tryParse(
                              balanceController.text.replaceAll(',', '.'),
                            ) ??
                            0;
                        await finance.addAccount(
                          name: nameController.text,
                          type: type,
                          currency: currency,
                          cutoffDay: cutoffDay,
                          dueDay: dueDay,
                          limit: limit,
                          initialBalance: balance,
                        );
                        if (!context.mounted) return;
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(l10n.translate('saved_successfully'))),
                        );
                      },
                      child: Text(l10n.translate('save')),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
