import 'package:flutter/material.dart';

class AdminPanelPage extends StatelessWidget {
  const AdminPanelPage({super.key});

  static const routePath = '/admin';
  static const routeName = 'admin';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _AdminTile(
            title: 'Payment Providers',
            description: 'Stripe, iyzico, regional gateways',
            icon: Icons.payment,
          ),
          _AdminTile(
            title: 'Plans & Pricing',
            description: 'Configure Free, Pro, Premium tiers',
            icon: Icons.workspace_premium,
          ),
          _AdminTile(
            title: 'Feature Flags',
            description: 'Enable AI chat, bank sync, OCR limits',
            icon: Icons.flag_rounded,
          ),
          _AdminTile(
            title: 'AI Library',
            description: 'Manage suggestion templates with AI assistance',
            icon: Icons.auto_awesome_rounded,
          ),
        ],
      ),
    );
  }
}

class _AdminTile extends StatelessWidget {
  const _AdminTile({
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      ),
    );
  }
}
