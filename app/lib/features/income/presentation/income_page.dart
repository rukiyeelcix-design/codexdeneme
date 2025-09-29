import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../widgets/import_review_sheet.dart';

class IncomePage extends StatefulWidget {
  const IncomePage({super.key});

  static const routePath = '/income';
  static const routeName = 'income';

  @override
  State<IncomePage> createState() => _IncomePageState();
}

class _IncomePageState extends State<IncomePage> {
  bool _showForm = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final incomes = finance.incomes;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('income')),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner_rounded),
            tooltip: l10n.translate('scan'),
            onPressed: () => _showScanDialog(context, l10n),
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
            _IncomeForm(
              onSaved: () => setState(() => _showForm = false),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: incomes.length,
              itemBuilder: (context, index) {
                final income = incomes[index];
                final account = finance.accounts.firstWhere(
                  (element) => element.id == income.accountId,
                  orElse: () => FinanceAccount(
                    id: income.accountId,
                    name: 'Account',
                    type: 'Bank',
                    currency: income.currency,
                    balance: 0,
                  ),
                );
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    title: Text(income.description),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${DateFormat.yMMMd().format(income.date)} · ${account.name}'),
                        if (income.mainCategory != null)
                          Text('${income.mainCategory} › ${income.subCategory ?? ''}'),
                      ],
                    ),
                    trailing: Text(finance.formatCurrency(income.amount)),
                    onLongPress: () => finance.removeTransaction(income.id),
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
    await showImportReviewSheet(context, TransactionKind.income);
  }
}

class _IncomeForm extends StatefulWidget {
  const _IncomeForm({required this.onSaved});

  final VoidCallback onSaved;

  @override
  State<_IncomeForm> createState() => _IncomeFormState();
}

class _IncomeFormState extends State<_IncomeForm> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
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
    _RepeatMemory.prefill('income_description', _descriptionController);
    _RepeatMemory.prefill('income_amount', _amountController);
    _RepeatMemory.prefill('income_main_category', null, onSelect: (value) {
      _mainCategory = value;
    });
    _RepeatMemory.prefill('income_sub_category', null, onSelect: (value) {
      _subCategory = value;
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final finance = context.watch<FinanceDataProvider>();
    final l10n = context.localization;
    final categories = finance.incomeCategories;

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
                  fieldKey: 'income_description',
                  controller: _descriptionController,
                  label: l10n.translate('description'),
                  validator: (value) =>
                      value == null || value.isEmpty ? l10n.translate('required') : null,
                ),
                const SizedBox(height: 12),
                _RepeatField(
                  fieldKey: 'income_amount',
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
                      DropdownMenuItem(
                        value: account.id,
                        child: Text(account.name),
                      ),
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
                    _RepeatMemory.updateValue('income_main_category', value ?? '');
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
                    _RepeatMemory.updateValue('income_sub_category', value ?? '');
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
                      await finance.addTransaction(
                        accountId: _accountId!,
                        kind: TransactionKind.income,
                        date: _selectedDate,
                        description: _descriptionController.text,
                        amount: amount,
                        mainCategory: _mainCategory,
                        subCategory: _subCategory,
                        paid: true,
                        note: _noteController.text.isEmpty ? null : _noteController.text,
                      );
                      _RepeatMemory.updateValue(
                          'income_description', _descriptionController.text);
                      _RepeatMemory.updateValue('income_amount', _amountController.text);
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

class _RepeatField extends StatefulWidget {
  const _RepeatField({
    required this.fieldKey,
    required this.controller,
    required this.label,
    this.keyboardType,
    this.validator,
  });

  final String fieldKey;
  final TextEditingController controller;
  final String label;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;

  @override
  State<_RepeatField> createState() => _RepeatFieldState();
}

class _RepeatFieldState extends State<_RepeatField> {
  @override
  void initState() {
    super.initState();
    _RepeatMemory.prefill(widget.fieldKey, widget.controller);
  }

  @override
  Widget build(BuildContext context) {
    final isActive = _RepeatMemory.isActive(widget.fieldKey);
    return TextFormField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: GestureDetector(
          onTap: () {
            setState(() => _RepeatMemory.toggle(widget.fieldKey, widget.controller.text));
          },
          onDoubleTap: () {
            setState(() => _RepeatMemory.reset(widget.fieldKey, widget.controller));
          },
          child: Icon(
            Icons.repeat_rounded,
            color: isActive ? Colors.green : null,
          ),
        ),
      ),
      validator: widget.validator,
      onChanged: (value) {
        if (_RepeatMemory.isActive(widget.fieldKey)) {
          _RepeatMemory.updateValue(widget.fieldKey, value);
        }
      },
    );
  }
}

class _RepeatMemory {
  static final Map<String, String> _values = {};
  static final Set<String> _active = {};

  static void toggle(String key, String currentValue) {
    if (_active.contains(key)) {
      _active.remove(key);
    } else {
      _active.add(key);
      _values[key] = currentValue;
    }
  }

  static void reset(String key, TextEditingController? controller) {
    _active.remove(key);
    _values.remove(key);
    controller?.clear();
  }

  static bool isActive(String key) => _active.contains(key);

  static void updateValue(String key, String value) {
    if (_active.contains(key)) {
      _values[key] = value;
    }
  }

  static void prefill(String key, TextEditingController? controller, {void Function(String value)? onSelect}) {
    if (_active.contains(key)) {
      final value = _values[key];
      if (value != null) {
        if (controller != null) {
          controller.text = value;
        } else {
          onSelect?.call(value);
        }
      }
    }
  }
}
