import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../core/providers/finance_provider.dart';
import '../core/services/import_service.dart';
import 'plan_selector.dart';

Future<void> showImportReviewSheet(
  BuildContext context,
  TransactionKind kind,
) async {
  final l10n = context.localization;
  final finance = context.read<FinanceDataProvider>();
  if (!finance.canScanDocuments) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('scan_limit_reached'))),
      );
      await showPlanSelector(context);
    }
    return;
  }

  final candidates = await OcrImportService.pickCandidates(kind);
  if (candidates.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.translate('no_candidates_found'))),
      );
    }
    return;
  }

  if (!context.mounted) return;
  await finance.registerScanUsage();
  if (finance.accounts.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.translate('no_accounts_available'))),
    );
    return;
  }

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => _ImportReviewSheet(
      kind: kind,
      finance: finance,
      candidates: candidates,
    ),
  );
}

class _ImportReviewSheet extends StatefulWidget {
  const _ImportReviewSheet({
    required this.kind,
    required this.finance,
    required this.candidates,
  });

  final TransactionKind kind;
  final FinanceDataProvider finance;
  final List<ImportCandidate> candidates;

  @override
  State<_ImportReviewSheet> createState() => _ImportReviewSheetState();
}

class _ImportReviewSheetState extends State<_ImportReviewSheet> {
  late String? _selectedAccount;
  late List<bool> _include;
  late List<bool> _paidSelections;
  late List<String?> _mainSelections;
  late List<String?> _subSelections;
  late List<List<CategorySuggestion>> _suggestionCache;
  bool _saving = false;

  Map<String, List<String>> get _categories => widget.kind == TransactionKind.income
      ? widget.finance.incomeCategories
      : widget.finance.expenseCategories;

  @override
  void initState() {
    super.initState();
    _selectedAccount = widget.finance.accounts.isNotEmpty
        ? widget.finance.accounts.first.id
        : null;
    _include = List<bool>.filled(widget.candidates.length, true);
    _paidSelections = widget.candidates.map((e) => e.paid).toList();
    _suggestionCache = widget.candidates
        .map((candidate) => widget.finance
            .suggestCategoriesFor(candidate.description, widget.kind))
        .toList();
    _mainSelections = List.generate(widget.candidates.length, (index) {
      final candidate = widget.candidates[index];
      return candidate.mainCategory ??
          (_suggestionCache[index].isNotEmpty
              ? _suggestionCache[index].first.main
              : (_categories.keys.isNotEmpty ? _categories.keys.first : null));
    });
    _subSelections = List.generate(widget.candidates.length, (index) {
      final candidate = widget.candidates[index];
      if (candidate.subCategory != null) {
        return candidate.subCategory;
      }
      if (_suggestionCache[index].isNotEmpty) {
        return _suggestionCache[index].first.sub;
      }
      final main = _mainSelections[index];
      final subs = main != null ? _categories[main] ?? [] : <String>[];
      return subs.isNotEmpty ? subs.first : null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    final accounts = widget.finance.accounts;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.translate('review_import'),
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedAccount,
                onChanged: (value) => setState(() => _selectedAccount = value),
                decoration: InputDecoration(
                  labelText: l10n.translate('select_account'),
                ),
                items: [
                  for (final account in accounts)
                    DropdownMenuItem(
                      value: account.id,
                      child: Text('${account.name} (${account.currency})'),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < widget.candidates.length; i++)
                _buildCandidateCard(context, i, l10n),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () => Navigator.of(context).maybePop(),
                      child: Text(l10n.translate('cancel')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _saving ? null : _submit,
                      child: _saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.translate('add_selected')),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCandidateCard(
    BuildContext context,
    int index,
    AppLocalizationDelegate l10n,
  ) {
    final candidate = widget.candidates[index];
    final main = _mainSelections[index];
    final subs = main != null ? _categories[main] ?? [] : <String>[];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              value: _include[index],
              title: Text(candidate.description),
              subtitle: Text(
                '${candidate.date.toIso8601String().split('T').first} · ${candidate.amount.toStringAsFixed(2)} ${candidate.currency}',
              ),
              onChanged: (value) => setState(() => _include[index] = value ?? true),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _mainSelections[index],
              decoration: InputDecoration(
                labelText: l10n.translate('main_category'),
              ),
              items: [
                for (final entry in _categories.entries)
                  DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.key),
                  ),
              ],
              onChanged: (value) {
                setState(() {
                  _mainSelections[index] = value;
                  final newSubs = value != null ? _categories[value] ?? [] : <String>[];
                  _subSelections[index] = newSubs.isNotEmpty ? newSubs.first : null;
                });
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _subSelections[index],
              decoration: InputDecoration(
                labelText: l10n.translate('sub_category'),
              ),
              items: [
                for (final sub in subs)
                  DropdownMenuItem(value: sub, child: Text(sub)),
              ],
              onChanged: (value) => setState(() => _subSelections[index] = value),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.translate('add_sub_category')),
                onPressed: main == null ? null : () => _addSubCategory(main!, index),
              ),
            ),
            SwitchListTile(
              value: _paidSelections[index],
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.translate('mark_as_paid')),
              onChanged: (value) => setState(() => _paidSelections[index] = value),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addSubCategory(String main, int index) async {
    final controller = TextEditingController();
    final l10n = context.localization;
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('add_sub_category')),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: l10n.translate('sub_category'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.translate('cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.translate('save')),
          ),
        ],
      ),
    );
    controller.dispose();
    if (result == null || result.isEmpty) return;
    await widget.finance.addCategory(
      income: widget.kind == TransactionKind.income,
      main: main,
      subCategory: result,
    );
    setState(() {
      _subSelections[index] = result;
    });
  }

  Future<void> _submit() async {
    if (_selectedAccount == null) return;
    setState(() => _saving = true);
    try {
      for (var i = 0; i < widget.candidates.length; i++) {
        if (!_include[i]) continue;
        final candidate = widget.candidates[i];
        await widget.finance.addTransaction(
          accountId: _selectedAccount!,
          kind: candidate.kind,
          date: candidate.date,
          description: candidate.description,
          amount: candidate.amount,
          currency: candidate.currency,
          mainCategory: _mainSelections[i],
          subCategory: _subSelections[i],
          installments: candidate.installments,
          paid: _paidSelections[i],
          note: candidate.note,
        );
      }
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
