import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/providers/finance_provider.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({super.key});

  static const routePath = '/categories';
  static const routeName = 'categories';

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final expenses = finance.expenseCategories;
    final incomes = finance.incomeCategories;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.translate('categories'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Gider Kategorileri', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final entry in expenses.entries)
            _CategoryCard(
              title: entry.key,
              subCategories: entry.value,
              active: finance.categoryActive(entry.key),
              onToggle: (value) => finance.toggleCategoryActive(entry.key, value),
            ),
          const SizedBox(height: 24),
          Text('Gelir Kategorileri', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final entry in incomes.entries)
            _CategoryCard(
              title: entry.key,
              subCategories: entry.value,
              active: finance.categoryActive(entry.key),
              onToggle: (value) => finance.toggleCategoryActive(entry.key, value),
            ),
        ],
      ),
    );
  }
}

class _CategoryCard extends StatefulWidget {
  const _CategoryCard({
    required this.title,
    required this.subCategories,
    required this.active,
    required this.onToggle,
  });

  final String title;
  final List<String> subCategories;
  final bool active;
  final ValueChanged<bool> onToggle;

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard> {
  final TextEditingController _controller = TextEditingController();
  late List<String> _items;
  late bool _active;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.subCategories);
    _active = widget.active;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        title: Text(widget.title),
        trailing: Switch(
          value: _active,
          onChanged: (value) {
            setState(() => _active = value);
            widget.onToggle(value);
          },
        ),
        children: [
          for (final item in _items)
            ListTile(
              title: Text(item),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Alt kategori ekle'),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () {
                    if (_controller.text.isEmpty) return;
                    setState(() => _items.add(_controller.text));
                    _controller.clear();
                  },
                  child: const Icon(Icons.add),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
