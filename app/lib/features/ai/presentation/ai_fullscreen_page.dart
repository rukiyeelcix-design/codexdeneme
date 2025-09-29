import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';
import '../../../widgets/plan_selector.dart';
import '../../settings/presentation/settings_sheet.dart';

class AiFullscreenPage extends StatefulWidget {
  const AiFullscreenPage({super.key});

  static const routePath = '/ai';
  static const routeName = 'ai';

  @override
  State<AiFullscreenPage> createState() => _AiFullscreenPageState();
}

class _AiFullscreenPageState extends State<AiFullscreenPage> {
  final TextEditingController _controller = TextEditingController();
  final List<_AiMessage> _messages = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_messages.isEmpty) {
      final l10n = context.localization;
      _messages.add(
        _AiMessage(
          role: 'assistant',
          content: l10n.translate('ai_model_salute').replaceAll('{model}', 'Gemini'),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final canChat = finance.canUseAiChat;
    final quickActions = [
      _QuickAction(
        label: l10n.translate('ai_quick_summary'),
        handler: () => _appendAssistantMessage(_buildMonthlySummary(finance, l10n)),
      ),
      _QuickAction(
        label: l10n.translate('ai_quick_risky'),
        handler: () => _appendAssistantMessage(_buildRiskyPayments(finance, l10n)),
      ),
      _QuickAction(
        label: l10n.translate('ai_quick_budget'),
        handler: () => _appendAssistantMessage(_buildBudgetHints(finance, l10n)),
      ),
      _QuickAction(
        label: l10n.translate('ai_quick_categories'),
        handler: () => _appendAssistantMessage(_buildCategoryOverview(finance, l10n)),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('ai_assistant')),
        actions: [
          IconButton(
            icon: const Icon(Icons.link_rounded),
            tooltip: l10n.translate('ai_add_api'),
            onPressed: () {
              GoRouter.of(context).push(SettingsSheet.routePath);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                for (final action in quickActions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(action.label),
                      onPressed: action.handler,
                    ),
                  ),
              ],
            ),
          ),
          if (!canChat)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: Theme.of(context).colorScheme.surfaceVariant,
                child: ListTile(
                  leading: const Icon(Icons.lock_rounded),
                  title: Text(l10n.translate('ai_chat_locked')),
                  subtitle: Text(l10n.translate('upgrade_to_chat')),
                  trailing: FilledButton(
                    onPressed: () => showPlanSelector(context),
                    child: Text(l10n.translate('upgrade_plan')),
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message.role == 'user';
                return Align(
                  alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUser
                          ? Theme.of(context).colorScheme.primaryContainer
                          : Theme.of(context).colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(message.content),
                  ),
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: l10n.translate('ai_prompt_placeholder'),
                        border: const OutlineInputBorder(),
                        enabled: canChat,
                      ),
                      minLines: 1,
                      maxLines: 4,
                      readOnly: !canChat,
                      onTap: canChat
                          ? null
                          : () async {
                              await showPlanSelector(context);
                            },
                    ),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    onPressed: canChat ? _handleSend : () => showPlanSelector(context),
                    child: const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    final finance = context.read<FinanceDataProvider>();
    if (!finance.canUseAiChat) {
      await showPlanSelector(context);
      return;
    }
    if (_controller.text.isEmpty) return;
    final prompt = _controller.text.trim();
    setState(() {
      _messages.add(_AiMessage(role: 'user', content: prompt));
      _controller.clear();
    });
    final response = await _handlePrompt(prompt);
    if (!mounted) return;
    setState(() {
      _messages.add(_AiMessage(role: 'assistant', content: response));
    });
  }

  Future<String> _handlePrompt(String prompt) async {
    final finance = context.read<FinanceDataProvider>();
    final l10n = context.localization;
    final lower = prompt.toLowerCase();
    if (lower.contains('kategori') && lower.contains('ekle') ||
        lower.contains('add category')) {
      return _handleCategoryCreation(finance, l10n, prompt, lower);
    }
    if (lower.contains('tasarruf') || lower.contains('savings')) {
      return _buildBudgetHints(finance, l10n);
    }
    if (lower.contains('risk') || lower.contains('ödemeler')) {
      return _buildRiskyPayments(finance, l10n);
    }
    if (lower.contains('özet') || lower.contains('summary') || lower.contains('analiz')) {
      return _buildMonthlySummary(finance, l10n);
    }
    if (lower.contains('kategori') || lower.contains('category')) {
      return _buildCategoryOverview(finance, l10n);
    }
    return _buildGenericInsight(finance, l10n);
  }

  void _appendAssistantMessage(String content) {
    setState(() {
      _messages.add(_AiMessage(role: 'assistant', content: content));
    });
  }

  String _handleCategoryCreation(
    FinanceDataProvider finance,
    AppLocalizationDelegate l10n,
    String original,
    String lower,
  ) {
    final bool incomeCategory = lower.contains('gelir') || lower.contains('income');
    final separators = ['>', ':', '->'];
    String working = original;
    for (final keyword in ['kategori ekle', 'kategori oluştur', 'add category', 'create category']) {
      final index = working.toLowerCase().indexOf(keyword);
      if (index != -1) {
        working = working.substring(index + keyword.length).trim();
        break;
      }
    }
    String main = working;
    String? sub;
    for (final separator in separators) {
      if (working.contains(separator)) {
        final parts = working.split(separator);
        main = parts[0].trim();
        sub = parts.length > 1 ? parts[1].trim() : null;
        break;
      }
    }
    if (main.isEmpty) {
      return l10n.translate('ai_unrecognized_command');
    }
    unawaited(finance.addCategory(income: incomeCategory, main: main, subCategory: sub));
    return l10n
        .translate('ai_category_created')
        .replaceAll('{category}', main)
        .replaceAll('{type}', incomeCategory ? l10n.translate('income') : l10n.translate('expense'));
  }

  String _buildMonthlySummary(FinanceDataProvider finance, AppLocalizationDelegate l10n) {
    final now = DateTime.now();
    final current = finance.monthlySummary(now);
    final previousMonth = DateTime(now.year, now.month - 1, 1);
    final previous = finance.monthlySummary(previousMonth);
    final currencyFormatter = NumberFormat.currency(symbol: '₺', locale: l10n.currentLocale.languageCode);
    double percentChange(double current, double previous) {
      if (previous == 0) return 100;
      return ((current - previous) / previous) * 100;
    }

    final incomeChange = percentChange(current['income']!, previous['income']!);
    final expenseChange = percentChange(current['expense']!, previous['expense']!);
    final topCategories = finance.topExpenseCategories(limit: 3);

    final buffer = StringBuffer()
      ..writeln(l10n.translate('ai_summary_header'))
      ..writeln('- ${l10n.translate('income')}: ${currencyFormatter.format(current['income'])} (${incomeChange.toStringAsFixed(1)}%)')
      ..writeln('- ${l10n.translate('expense')}: ${currencyFormatter.format(current['expense'])} (${expenseChange.toStringAsFixed(1)}%)')
      ..writeln('- ${l10n.translate('net')}: ${currencyFormatter.format(current['net'])}');
    if (topCategories.isNotEmpty) {
      buffer.writeln(l10n.translate('ai_top_categories'));
      for (final category in topCategories) {
        buffer.writeln('• ${category.main}');
      }
    }
    return buffer.toString();
  }

  String _buildRiskyPayments(FinanceDataProvider finance, AppLocalizationDelegate l10n) {
    final upcoming = finance.upcomingPaymentsWithin(days: 30);
    if (upcoming.isEmpty) {
      return l10n.translate('ai_no_risky_payments');
    }
    final formatter = DateFormat.yMd(l10n.currentLocale.languageCode);
    final buffer = StringBuffer(l10n.translate('ai_risky_payments_header'));
    for (final tx in upcoming) {
      buffer.writeln(
          '• ${tx.description} — ${formatter.format(tx.firstInstallment)} (${tx.amount.toStringAsFixed(2)} ${tx.currency})');
    }
    return buffer.toString();
  }

  String _buildBudgetHints(FinanceDataProvider finance, AppLocalizationDelegate l10n) {
    final expenses = finance.expenses;
    if (expenses.isEmpty) {
      return l10n.translate('ai_no_expense_data');
    }
    final averageExpense = expenses.fold<double>(0, (value, element) => value + element.amount) / expenses.length;
    final highest = finance.topExpenseCategories(limit: 2);
    final buffer = StringBuffer()
      ..writeln(l10n.translate('ai_savings_intro'))
      ..writeln('- ${l10n.translate('ai_average_expense')}: ${averageExpense.toStringAsFixed(2)}')
      ..writeln(l10n.translate('ai_focus_categories'));
    for (final item in highest) {
      buffer.writeln('• ${item.main}');
    }
    buffer.writeln(l10n.translate('ai_rule_of_three'));
    return buffer.toString();
  }

  String _buildCategoryOverview(FinanceDataProvider finance, AppLocalizationDelegate l10n) {
    final suggestions = finance.topExpenseCategories(limit: 5);
    if (suggestions.isEmpty) {
      return l10n.translate('ai_no_category_data');
    }
    final buffer = StringBuffer(l10n.translate('ai_category_overview'));
    for (final suggestion in suggestions) {
      buffer.writeln('• ${suggestion.main}');
    }
    buffer.writeln(l10n.translate('ai_category_tip'));
    return buffer.toString();
  }

  String _buildGenericInsight(FinanceDataProvider finance, AppLocalizationDelegate l10n) {
    final summary = _buildMonthlySummary(finance, l10n);
    final risky = _buildRiskyPayments(finance, l10n);
    return '$summary\n\n$risky';
  }
}

class _AiMessage {
  const _AiMessage({required this.role, required this.content});

  final String role;
  final String content;
}

class _QuickAction {
  const _QuickAction({required this.label, required this.handler});

  final String label;
  final VoidCallback handler;
}
