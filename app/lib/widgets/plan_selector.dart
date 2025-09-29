import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/localization/app_localizations.dart';
import '../core/providers/finance_provider.dart';

Future<void> showPlanSelector(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => const _PlanSelectorSheet(),
  );
}

class _PlanSelectorSheet extends StatelessWidget {
  const _PlanSelectorSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final plans = PlanTier.values;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.translate('choose_plan'),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              '${l10n.translate('current_plan')}: ${l10n.translate('plan_${finance.effectivePlan.name}')} ',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (finance.isTrialActive) ...[
              const SizedBox(height: 4),
              Chip(
                avatar: const Icon(Icons.timer_rounded),
                label: Text(
                  '${l10n.translate('trial_badge')}: ${finance.remainingTrialDays} ${l10n.translate('days_label')}',
                ),
              ),
            ],
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: plans.length,
                itemBuilder: (context, index) {
                  final plan = plans[index];
                  return _PlanCard(plan: plan);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({required this.plan});

  final PlanTier plan;

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    final finance = context.watch<FinanceDataProvider>();
    final features = _featuresFor(plan, l10n);
    final planTitle = l10n.translate('plan_${plan.name}');
    final isSelected = finance.subscribedPlan == plan;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  plan == PlanTier.premium
                      ? Icons.workspace_premium_rounded
                      : (plan == PlanTier.pro
                          ? Icons.star_outline_rounded
                          : Icons.lock_open_rounded),
                ),
                const SizedBox(width: 8),
                Text(
                  planTitle,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                if (isSelected)
                  Chip(
                    label: Text(l10n.translate('plan_selected')),
                    avatar: const Icon(Icons.check_circle_rounded),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            for (final feature in features)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.check_rounded, size: 18),
                    const SizedBox(width: 8),
                    Expanded(child: Text(feature)),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: isSelected
                    ? null
                    : () async {
                        await finance.updatePlan(plan);
                        if (context.mounted) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(l10n.translate('upgrade_successful')),
                            ),
                          );
                        }
                      },
                child: Text(
                  isSelected
                      ? l10n.translate('plan_selected')
                      : l10n.translate('upgrade_plan'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _featuresFor(
    PlanTier tier,
    AppLocalizationDelegate l10n,
  ) {
    switch (tier) {
      case PlanTier.free:
        return [
          l10n.translate('plan_free_feature_1'),
          l10n.translate('plan_free_feature_2'),
          l10n.translate('plan_free_feature_3'),
        ];
      case PlanTier.pro:
        return [
          l10n.translate('plan_pro_feature_1'),
          l10n.translate('plan_pro_feature_2'),
          l10n.translate('plan_pro_feature_3'),
        ];
      case PlanTier.premium:
        return [
          l10n.translate('plan_premium_feature_1'),
          l10n.translate('plan_premium_feature_2'),
          l10n.translate('plan_premium_feature_3'),
        ];
    }
  }
}
