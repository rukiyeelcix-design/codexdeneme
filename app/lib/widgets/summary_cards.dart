import 'package:flutter/material.dart';

import '../core/localization/app_localizations.dart';

class SummaryCards extends StatelessWidget {
  const SummaryCards({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final cards = [
      _SummaryCardData(
        title: l10n.translate('total_debt'),
        value: '₺18.540,00',
        color: Colors.amber.shade400,
      ),
      _SummaryCardData(
        title: l10n.translate('paid'),
        value: '₺12.200,00',
        color: Colors.green.shade400,
      ),
      _SummaryCardData(
        title: l10n.translate('pending'),
        value: '₺6.340,00',
        color: Colors.red.shade300,
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < cards.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == cards.length - 1 ? 0 : 8),
              child: Container(
                decoration: BoxDecoration(
                  color: cards[i].color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cards[i].title,
                      style: Theme.of(context).textTheme.labelLarge,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      cards[i].value,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _SummaryCardData {
  const _SummaryCardData({
    required this.title,
    required this.value,
    required this.color,
  });

  final String title;
  final String value;
  final Color color;
}
