import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/localization/app_localizations.dart';
import '../../dashboard/presentation/dashboard_page.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  static const routePath = '/onboarding';
  static const routeName = 'onboarding';
  static const finishedKey = 'onboarding_finished';

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _controller = PageController();
  final List<_OnboardingSlide> _slides = const [
    _OnboardingSlide(
      title: 'Language & Currency',
      description: 'Choose your preferred language and base currency.',
    ),
    _OnboardingSlide(
      title: 'Quick Add',
      description: 'Use the floating action button to add income and expenses.',
    ),
    _OnboardingSlide(
      title: 'Scan Documents',
      description: 'Capture receipts or import PDFs to auto-extract details.',
    ),
    _OnboardingSlide(
      title: 'Analytics',
      description: 'Track budgets, habits, and forecasts in one place.',
    ),
    _OnboardingSlide(
      title: 'AI Assistant',
      description: 'Chat with Gemini, Grok, or OpenAI to optimise finances.',
    ),
  ];

  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.localization;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_index + 1) / _slides.length),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (value) => setState(() => _index = value),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, size: 72, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(height: 32),
                        Text(slide.title, style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 16),
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => _complete(context),
                    child: Text(l10n.translate('skip')),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      if (_index == _slides.length - 1) {
                        _complete(context);
                      } else {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    child: Text(_index == _slides.length - 1 ? 'Start' : 'Next'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _complete(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(OnboardingFlow.finishedKey, true);
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed(DashboardPage.routePath);
  }
}

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
