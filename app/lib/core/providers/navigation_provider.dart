import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class NavDestination {
  const NavDestination({
    required this.key,
    required this.icon,
    required this.label,
    required this.route,
  });

  final String key;
  final IconData icon;
  final String label;
  final String route;
}

class NavigationProvider extends ChangeNotifier {
  static const _boxName = 'nav_preferences';
  static const _orderKey = 'nav_order';

  NavigationProvider() {
    _restoreOrder();
  }

  final List<NavDestination> _defaultDestinations = const [
    NavDestination(
      key: 'accounts',
      icon: Icons.account_balance_wallet_rounded,
      label: 'accounts_cards',
      route: '/accounts',
    ),
    NavDestination(
      key: 'income',
      icon: Icons.trending_up_rounded,
      label: 'income',
      route: '/income',
    ),
    NavDestination(
      key: 'dashboard',
      icon: Icons.dashboard_rounded,
      label: 'dashboard',
      route: '/dashboard',
    ),
    NavDestination(
      key: 'expense',
      icon: Icons.shopping_bag_rounded,
      label: 'expense',
      route: '/expense',
    ),
    NavDestination(
      key: 'analytics',
      icon: Icons.analytics_outlined,
      label: 'analytics',
      route: '/analytics',
    ),
    NavDestination(
      key: 'netpnl',
      icon: Icons.savings_rounded,
      label: 'net_pnl',
      route: '/netpnl',
    ),
  ];

  late List<NavDestination> _destinations = _defaultDestinations;

  List<NavDestination> get destinations => List.unmodifiable(_destinations);

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = List.of(_destinations);
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    _destinations = list;
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final box = await Hive.openBox(_boxName);
    await box.put(_orderKey, _destinations.map((e) => e.key).toList());
  }

  Future<void> _restoreOrder() async {
    final box = await Hive.openBox(_boxName);
    final stored = box.get(_orderKey) as List<dynamic>?;
    if (stored == null) {
      _destinations = _defaultDestinations;
      return;
    }
    final keyed = {for (final dest in _defaultDestinations) dest.key: dest};
    _destinations = [
      for (final key in stored)
        if (keyed.containsKey(key)) keyed[key]!,
    ];
    for (final dest in _defaultDestinations) {
      if (!_destinations.any((element) => element.key == dest.key)) {
        _destinations = [..._destinations, dest];
      }
    }
    notifyListeners();
  }
}
