import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../widgets/import_review_sheet.dart';
import '../../income/presentation/income_page.dart' show _RepeatField, _RepeatMemory;

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  static const routePath = '/expense';
  static const routeName = 'expense';

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool _showForm = false;
  int _matrixMonths = 6;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final expenses = finance.expenses;
    final matrix = finance.installmentMatrix(_matrixMonths);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('expense')),
        actions: [
          IconButton(
            icon: const Icon(Icons.document_scanner_rounded),
            tooltip: l10n.translate('scan'),
            onPressed: () => _showScanDialog(context, l10n),
          ),
          PopupMenuButton<int>(
            initialValue: _matrixMonths,
            onSelected: (value) => setState(() => _matrixMonths = value),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 3, child: Text('3 ay')),
              PopupMenuItem(value: 6, child: Text('6 ay')),
              PopupMenuItem(value: 9, child: Text('9 ay')),
              PopupMenuItem(value: 12, child: Text('12 ay')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: () => setState(() => _showForm = !_showForm),
                  child: Text(l10n.translate('add')),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.undo_rounded),
                  tooltip: l10n.translate('undo'),
                  onPressed: finance.canUndo ? finance.undo : null,
                ),
                IconButton(
                  icon: const Icon(Icons.redo_rounded),
                  tooltip: l10n.translate('redo'),
                  onPressed: finance.canRedo ? finance.redo : null,
                ),
              ],
            ),
          ),
          if (_showForm)
            _ExpenseForm(
              onSaved: () => setState(() => _showForm = false),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: _FutureMatrix(matrix: matrix, finance: finance),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: expenses.length,
              itemBuilder: (context, index) {
                final expense = expenses[index];
                final account = finance.accounts.firstWhere(
                  (element) => element.id == expense.accountId,
                  orElse: () => FinanceAccount(
                    id: expense.accountId,
                    name: 'Account',
                    type: 'Credit Card',
                    currency: expense.currency,
                    balance: 0,
                  ),
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(expense.description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${DateFormat.yMMMd().format(expense.date)} · ${account.name}'),
                        Text('Ekstre: ${expense.statementMonth}/${expense.statementYear}'),
                        if (expense.mainCategory != null)
                          Text('${expense.mainCategory} › ${expense.subCategory ?? ''}'),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(finance.formatCurrency(expense.amount)),
                        Switch(
                          value: expense.isPaid,
                          onChanged: (_) => finance.togglePaid(expense.id),
                        ),
                      ],
                    ),
                    onLongPress: () => finance.removeTransaction(expense.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showScanDialog(BuildContext context, AppLocalizationDelegate l10n) async {
    Navigator.of(context).maybePop();
    await showImportReviewSheet(context, TransactionKind.expense);
  }
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _installmentController = TextEditingController(text: '1');
  final _noteController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  String? _accountId;
  String? _mainCategory;
  String? _subCategory;

  @override
  void initState() {
    super.initState();
    final finance = context.read<FinanceDataProvider>();
    if (finance.accounts.isNotEmpty) {
      _accountId = finance.accounts.first.id;
    }
    _RepeatMemory.prefill('expense_description', _descriptionController);
    _RepeatMemory.prefill('expense_amount', _amountController);
    _RepeatMemory.prefill('expense_main_category', null, onSelect: (value) {
      _mainCategory = value;
    });
    _RepeatMemory.prefill('expense_sub_category', null, onSelect: (value) {
      _subCategory = value;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _installmentController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceDataProvider>();
    final l10n = context.localization;
    final categories = finance.expenseCategories;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _RepeatField(
                  fieldKey: 'expense_description',
                  controller: _descriptionController,
                  label: l10n.translate('description'),
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.translate('required') : null,
                ),
                const SizedBox(height: 12),
                _RepeatField(
                  fieldKey: 'expense_amount',
                  controller: _amountController,
                  label: l10n.translate('amount'),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.translate('required');
                    }
                    if (double.tryParse(value.replaceAll(',', '.')) == null) {
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
                  subtitle: Text(DateFormat.yMMMd().format(_selectedDate)),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      initialDate: _selectedDate,
                    );
                    if (picked != null) {
                      setState(() => _selectedDate = picked);
                    }
                  },
                ),
                DropdownButtonFormField<String>(
                  value: _accountId,
                  decoration: InputDecoration(labelText: l10n.translate('accounts_cards')),
                  items: [
                    for (final account in finance.accounts)
                      DropdownMenuItem(value: account.id, child: Text(account.name)),
                  ],
                  onChanged: (value) => setState(() => _accountId = value),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _mainCategory,
                  decoration: InputDecoration(labelText: l10n.translate('main_category')),
                  items: [
                    for (final entry in categories.entries)
                      DropdownMenuItem(value: entry.key, child: Text(entry.key)),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _mainCategory = value;
                      _subCategory = null;
                    });
                    _RepeatMemory.updateValue('expense_main_category', value ?? '');
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _subCategory,
                  decoration: InputDecoration(labelText: l10n.translate('sub_category')),
                  items: [
                    if (_mainCategory != null)
                      for (final item in categories[_mainCategory] ?? const [])
                        DropdownMenuItem(value: item, child: Text(item)),
                  ],
                  onChanged: (value) {
                    setState(() => _subCategory = value);
                    _RepeatMemory.updateValue('expense_sub_category', value ?? '');
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _installmentController,
                  decoration: InputDecoration(labelText: l10n.translate('installments')),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    final parsed = int.tryParse(value ?? '1');
                    if (parsed == null || parsed <= 0) {
                      return l10n.translate('invalid_number');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _noteController,
                  decoration: const InputDecoration(labelText: 'Not'),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.save_rounded),
                    label: Text(l10n.translate('save')),
                    onPressed: () async {
                      if (!( _formKey.currentState?.validate() ?? false)) return;
                      if (_accountId == null) return;
                      final amount =
                          double.parse(_amountController.text.replaceAll(',', '.'));
                      final installments = int.tryParse(_installmentController.text) ?? 1;
                      await finance.addTransaction(
                        accountId: _accountId!,
                        kind: TransactionKind.expense,
                        date: _selectedDate,
                        description: _descriptionController.text,
                        amount: amount,
                        mainCategory: _mainCategory,
                        subCategory: _subCategory,
                        installments: installments,
                        paid: false,
                        note: _noteController.text.isEmpty ? null : _noteController.text,
                      );
                      _RepeatMemory.updateValue(
                          'expense_description', _descriptionController.text);
                      _RepeatMemory.updateValue('expense_amount', _amountController.text);
                      if (!mounted) return;
                      widget.onSaved();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FutureMatrix extends StatelessWidget {
  const _FutureMatrix({required this.matrix, required this.finance});

  final Map<DateTime, double> matrix;
  final FinanceDataProvider finance;

  @override
  Widget build(BuildContext context) {
    final entries = matrix.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Gelecek Taksit Planı',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final entry in entries)
                    Container(
                      width: 140,
                      margin: const EdgeInsets.only(right: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Theme.of(context).dividerColor),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(DateFormat.yMMM().format(entry.key)),
                          const SizedBox(height: 8),
                          Text(
                            finance.formatCurrency(entry.value),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
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
