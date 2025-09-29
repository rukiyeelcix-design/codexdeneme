import 'dart:async';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../services/supabase_service.dart';

enum TransactionKind { income, expense, transfer }

enum TransactionStatus { paid, unpaid }

enum PlanTier { free, pro, premium }

class FinanceAccount {
  FinanceAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.currency,
    this.cutoffDay,
    this.dueDay,
    this.limit,
    this.balance = 0,
  });

  final String id;
  String name;
  String type;
  String currency;
  int? cutoffDay;
  int? dueDay;
  double? limit;
  double balance;

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'type': type,
      'currency': currency,
      'cutoffDay': cutoffDay,
      'dueDay': dueDay,
      'limit': limit,
      'balance': balance,
    };
  }

  factory FinanceAccount.fromMap(String id, Map<dynamic, dynamic> map) {
    return FinanceAccount(
      id: id,
      name: map['name'] as String? ?? '',
      type: map['type'] as String? ?? 'Bank',
      currency: map['currency'] as String? ?? 'TRY',
      cutoffDay: map['cutoffDay'] as int?,
      dueDay: map['dueDay'] as int?,
      limit: (map['limit'] as num?)?.toDouble(),
      balance: (map['balance'] as num?)?.toDouble() ?? 0,
    );
  }
}

class TransactionRecord {
  TransactionRecord({
    required this.id,
    required this.accountId,
    required this.kind,
    required this.date,
    required this.description,
    required this.amount,
    required this.currency,
    required this.statementMonth,
    required this.statementYear,
    required this.status,
    this.mainCategory,
    this.subCategory,
    this.note,
    this.installments = 1,
    DateTime? firstInstallment,
    DateTime? lastInstallment,
  })  : firstInstallment = firstInstallment ?? DateTime(date.year, date.month, date.day),
        lastInstallment = lastInstallment ?? DateTime(date.year, date.month, date.day);

  final String id;
  final String accountId;
  final TransactionKind kind;
  final DateTime date;
  final String description;
  final double amount;
  final String currency;
  final int statementMonth;
  final int statementYear;
  final TransactionStatus status;
  final String? mainCategory;
  final String? subCategory;
  final String? note;
  final int installments;
  final DateTime firstInstallment;
  final DateTime lastInstallment;

  bool get isExpense => kind == TransactionKind.expense;
  bool get isIncome => kind == TransactionKind.income;
  bool get isPaid => status == TransactionStatus.paid;

  Map<String, dynamic> toMap() {
    return {
      'accountId': accountId,
      'kind': kind.name,
      'date': date.toIso8601String(),
      'description': description,
      'amount': amount,
      'currency': currency,
      'statementMonth': statementMonth,
      'statementYear': statementYear,
      'status': status.name,
      'mainCategory': mainCategory,
      'subCategory': subCategory,
      'note': note,
      'installments': installments,
      'firstInstallment': firstInstallment.toIso8601String(),
      'lastInstallment': lastInstallment.toIso8601String(),
    };
  }

  factory TransactionRecord.fromMap(String id, Map<dynamic, dynamic> map) {
    return TransactionRecord(
      id: id,
      accountId: map['accountId'] as String,
      kind: TransactionKind.values.firstWhere(
        (element) => element.name == map['kind'],
        orElse: () => TransactionKind.expense,
      ),
      date: DateTime.parse(map['date'] as String),
      description: map['description'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
      currency: map['currency'] as String? ?? 'TRY',
      statementMonth: map['statementMonth'] as int? ?? DateTime.now().month,
      statementYear: map['statementYear'] as int? ?? DateTime.now().year,
      status: TransactionStatus.values.firstWhere(
        (element) => element.name == map['status'],
        orElse: () => TransactionStatus.unpaid,
      ),
      mainCategory: map['mainCategory'] as String?,
      subCategory: map['subCategory'] as String?,
      note: map['note'] as String?,
      installments: map['installments'] as int? ?? 1,
      firstInstallment: DateTime.parse(map['firstInstallment'] as String),
      lastInstallment: DateTime.parse(map['lastInstallment'] as String),
    );
  }
}

class CategoryNode {
  CategoryNode({
    required this.name,
    required this.subCategories,
    this.active = true,
  });

  final String name;
  final List<String> subCategories;
  bool active;
}

class CategorySuggestion {
  const CategorySuggestion({
    required this.main,
    this.sub,
    this.confidence = 0,
  });

  final String main;
  final String? sub;
  final double confidence;
}

class AccountSpending {
  AccountSpending({
    required this.account,
    required this.paid,
    required this.pending,
  });

  final FinanceAccount account;
  final double paid;
  final double pending;

  double get total => paid + pending;
}

class _FinanceSnapshot {
  _FinanceSnapshot({required this.accounts, required this.transactions});

  final List<Map<String, dynamic>> accounts;
  final List<Map<String, dynamic>> transactions;
}

class FinanceDataProvider extends ChangeNotifier {
  FinanceDataProvider();

  static const _accountsBoxName = 'finance_accounts';
  static const _transactionsBoxName = 'finance_transactions';
  static const _settingsBoxName = 'finance_settings';
  static const _planKey = 'plan_tier';
  static const _trialStartKey = 'trial_start';
  static const _scanMonthKey = 'scan_month';
  static const _scanCountKey = 'scan_count';

  final Uuid _uuid = const Uuid();
  late Box<dynamic> _accountsBox;
  late Box<dynamic> _transactionsBox;
  late Box<dynamic> _settingsBox;

  bool _initialized = false;
  bool get initialized => _initialized;

  final List<_FinanceSnapshot> _undoStack = [];
  final List<_FinanceSnapshot> _redoStack = [];

  bool _syncEnabled = false;
  bool get syncEnabled => _syncEnabled;

  String? _profileId;
  String get profileId => _profileId ?? 'local';

  DateTime? _lastSync;
  DateTime? get lastSync => _lastSync;

  Timer? _syncDebounce;
  bool _syncInProgress = false;

  List<FinanceAccount> _accounts = [];
  List<TransactionRecord> _transactions = [];

  final Map<String, CategoryNode> _expenseCategories =
      Map.fromEntries(defaultExpenseCategories.entries.map(
    (e) => MapEntry(
      e.key,
      CategoryNode(name: e.key, subCategories: List.of(e.value)),
    ),
  ));
  final Map<String, CategoryNode> _incomeCategories =
      Map.fromEntries(defaultIncomeCategories.entries.map(
    (e) => MapEntry(
      e.key,
      CategoryNode(name: e.key, subCategories: List.of(e.value)),
    ),
  ));

  String _defaultCurrency = 'TRY';
  String get defaultCurrency => _defaultCurrency;

  PlanTier _planTier = PlanTier.free;
  DateTime? _trialStart;
  static const Duration _trialDuration = Duration(days: 30);
  DateTime? _scanMonthAnchor;
  int _monthlyScanCount = 0;

  PlanTier get subscribedPlan => _planTier;
  PlanTier get effectivePlan => isTrialActive ? PlanTier.premium : _planTier;
  DateTime? get trialEnds =>
      _trialStart != null ? _trialStart!.add(_trialDuration) : null;
  bool get isTrialActive =>
      trialEnds != null && DateTime.now().isBefore(trialEnds!);
  int get remainingTrialDays {
    if (!isTrialActive || trialEnds == null) return 0;
    final diff = trialEnds!.difference(DateTime.now()).inDays;
    return max(0, diff + 1);
  }

  int get freeScanLimit => 2;
  int get remainingFreeScans =>
      (!isTrialActive && effectivePlan == PlanTier.free)
          ? max(0, freeScanLimit - _monthlyScanCount)
          : -1;

  bool get canScanDocuments =>
      isTrialActive || effectivePlan != PlanTier.free || remainingFreeScans > 0;
  bool get canUseAiChat => isTrialActive || effectivePlan != PlanTier.free;
  bool get canAccessStandardAnalytics =>
      isTrialActive || effectivePlan != PlanTier.free;
  bool get canAccessPremiumAnalytics =>
      isTrialActive || effectivePlan == PlanTier.premium;
  int get monthlyScanCount => _monthlyScanCount;

  Future<void> initialize() async {
    if (_initialized) return;
    _accountsBox = await Hive.openBox<dynamic>(_accountsBoxName);
    _transactionsBox = await Hive.openBox<dynamic>(_transactionsBoxName);
    _settingsBox = await Hive.openBox<dynamic>(_settingsBoxName);
    _defaultCurrency = _settingsBox.get('currency', defaultValue: 'TRY') as String;
    _syncEnabled = _settingsBox.get('sync_enabled', defaultValue: false) as bool;
    _profileId = _settingsBox.get('profile_id') as String?;
    final storedPlan = _settingsBox.get(_planKey) as String?;
    if (storedPlan != null) {
      _planTier = PlanTier.values.firstWhere(
        (element) => element.name == storedPlan,
        orElse: () => PlanTier.free,
      );
    }
    final trialStartIso = _settingsBox.get(_trialStartKey) as String?;
    if (trialStartIso != null) {
      _trialStart = DateTime.tryParse(trialStartIso);
    }
    _monthlyScanCount =
        _settingsBox.get(_scanCountKey, defaultValue: 0) as int;
    final scanMonthIso = _settingsBox.get(_scanMonthKey) as String?;
    if (scanMonthIso != null) {
      _scanMonthAnchor = DateTime.tryParse(scanMonthIso);
    }
    await _ensureTrialStart();
    await _ensureScanWindow();
    final lastSyncIso = _settingsBox.get('last_sync') as String?;
    if (lastSyncIso != null) {
      _lastSync = DateTime.tryParse(lastSyncIso);
    }
    _restoreFromBoxes();
    _loadCategoriesFromSettings();
    if (_accounts.isEmpty) {
      await _seedInitialData();
    }
    if (_syncEnabled) {
      unawaited(_pullFromSupabase());
    }
    _initialized = true;
    notifyListeners();
  }

  void _restoreFromBoxes() {
    _accounts = [
      for (final entry in _accountsBox.keys)
        FinanceAccount.fromMap(entry as String, _accountsBox.get(entry) as Map)
    ];
    _transactions = [
      for (final entry in _transactionsBox.keys)
        TransactionRecord.fromMap(entry as String, _transactionsBox.get(entry) as Map)
    ];
    _transactions.sort((a, b) => b.date.compareTo(a.date));
  }

  void _loadCategoriesFromSettings() {
    final storedExpenses = _settingsBox.get('expense_categories');
    if (storedExpenses is Map) {
      _expenseCategories
        ..clear()
        ..addAll(storedExpenses.map((key, value) {
          final map = value as Map;
          final subs = (map['subs'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
          final active = map['active'] as bool? ?? true;
          return MapEntry(
            key.toString(),
            CategoryNode(name: key.toString(), subCategories: subs, active: active),
          );
        }));
    }

    final storedIncome = _settingsBox.get('income_categories');
    if (storedIncome is Map) {
      _incomeCategories
        ..clear()
        ..addAll(storedIncome.map((key, value) {
          final map = value as Map;
          final subs = (map['subs'] as List?)?.map((e) => e.toString()).toList() ?? <String>[];
          final active = map['active'] as bool? ?? true;
          return MapEntry(
            key.toString(),
            CategoryNode(name: key.toString(), subCategories: subs, active: active),
          );
        }));
    }
  }

  Future<void> _persistCategories() async {
    final expensePayload = _expenseCategories.map((key, value) {
      return MapEntry(key, {
        'subs': value.subCategories,
        'active': value.active,
      });
    });
    final incomePayload = _incomeCategories.map((key, value) {
      return MapEntry(key, {
        'subs': value.subCategories,
        'active': value.active,
      });
    });
    await _settingsBox.put('expense_categories', expensePayload);
    await _settingsBox.put('income_categories', incomePayload);
  }

  Future<void> _seedInitialData() async {
    final cardId = _uuid.v4();
    final bankId = _uuid.v4();
    final accounts = [
      FinanceAccount(
        id: cardId,
        name: 'Visa Platinum',
        type: 'Credit Card',
        currency: 'TRY',
        cutoffDay: 25,
        dueDay: 5,
        limit: 25000,
        balance: -7800,
      ),
      FinanceAccount(
        id: bankId,
        name: 'Everyday Current',
        type: 'Bank Account',
        currency: 'TRY',
        balance: 12500,
      ),
    ];
    for (final account in accounts) {
      await _accountsBox.put(account.id, account.toMap());
    }
    final now = DateTime.now();
    final transactions = [
      TransactionRecord(
        id: _uuid.v4(),
        accountId: cardId,
        kind: TransactionKind.expense,
        date: now.subtract(const Duration(days: 4)),
        description: 'Market alışverişi',
        amount: 850,
        currency: 'TRY',
        statementMonth: now.month,
        statementYear: now.year,
        status: TransactionStatus.unpaid,
        mainCategory: 'Alışveriş',
        subCategory: 'Market',
        installments: 1,
      ),
      TransactionRecord(
        id: _uuid.v4(),
        accountId: cardId,
        kind: TransactionKind.expense,
        date: now.subtract(const Duration(days: 10)),
        description: 'Elektrik faturası',
        amount: 620,
        currency: 'TRY',
        statementMonth: now.month,
        statementYear: now.year,
        status: TransactionStatus.paid,
        mainCategory: 'Faturalar',
        subCategory: 'Elektrik',
        installments: 1,
      ),
      TransactionRecord(
        id: _uuid.v4(),
        accountId: bankId,
        kind: TransactionKind.income,
        date: DateTime(now.year, now.month, 1),
        description: 'Maaş',
        amount: 32000,
        currency: 'TRY',
        statementMonth: now.month,
        statementYear: now.year,
        status: TransactionStatus.paid,
        mainCategory: 'Maaş & Ücretler',
        subCategory: 'Aylık Maaş',
        installments: 1,
      ),
      TransactionRecord(
        id: _uuid.v4(),
        accountId: bankId,
        kind: TransactionKind.expense,
        date: DateTime(now.year, now.month, 2),
        description: 'Kira ödemesi',
        amount: 11000,
        currency: 'TRY',
        statementMonth: now.month,
        statementYear: now.year,
        status: TransactionStatus.paid,
        mainCategory: 'Kira & Konut',
        subCategory: 'Ev Kirası',
        installments: 1,
      ),
    ];
    for (final tx in transactions) {
      await _transactionsBox.put(tx.id, tx.toMap());
    }
    _restoreFromBoxes();
  }

  Future<void> updatePlan(PlanTier tier) async {
    if (_planTier == tier) return;
    _planTier = tier;
    await _settingsBox.put(_planKey, tier.name);
    notifyListeners();
  }

  Future<void> _ensureTrialStart() async {
    if (_trialStart == null) {
      _trialStart = DateTime.now();
      await _settingsBox.put(
        _trialStartKey,
        _trialStart!.toIso8601String(),
      );
    }
  }

  Future<void> _ensureScanWindow() async {
    final now = DateTime.now();
    final anchor = DateTime(now.year, now.month);
    if (_scanMonthAnchor == null ||
        _scanMonthAnchor!.year != anchor.year ||
        _scanMonthAnchor!.month != anchor.month) {
      _scanMonthAnchor = anchor;
      _monthlyScanCount = 0;
      await _settingsBox.put(
        _scanMonthKey,
        _scanMonthAnchor!.toIso8601String(),
      );
      await _settingsBox.put(_scanCountKey, _monthlyScanCount);
    }
  }

  Future<void> registerScanUsage() async {
    if (isTrialActive || effectivePlan != PlanTier.free) {
      return;
    }
    await _ensureScanWindow();
    if (_monthlyScanCount >= freeScanLimit) {
      return;
    }
    _monthlyScanCount += 1;
    await _settingsBox.put(_scanCountKey, _monthlyScanCount);
    notifyListeners();
  }

  List<FinanceAccount> get accounts => List.unmodifiable(_accounts);

  List<TransactionRecord> get transactions => List.unmodifiable(_transactions);

  List<TransactionRecord> get incomes =>
      _transactions.where((element) => element.isIncome).toList(growable: false);

  List<TransactionRecord> get expenses =>
      _transactions.where((element) => element.isExpense).toList(growable: false);

  List<TransactionRecord> get unpaidExpenses =>
      expenses.where((element) => !element.isPaid).toList(growable: false);

  List<TransactionRecord> get paidExpenses =>
      expenses.where((element) => element.isPaid).toList(growable: false);

  double get totalIncome =>
      incomes.fold(0, (previousValue, element) => previousValue + element.amount);

  double get totalExpense =>
      expenses.fold(0, (previousValue, element) => previousValue + element.amount);

  double get outstandingDebt => unpaidExpenses
      .fold(0, (previousValue, element) => previousValue + element.amount);

  double get paidDebt => paidExpenses
      .fold(0, (previousValue, element) => previousValue + element.amount);

  double get netBalance => totalIncome - totalExpense;

  Map<String, List<String>> get expenseCategories =>
      _expenseCategories.map((key, value) => MapEntry(key, value.subCategories));
  Map<String, List<String>> get incomeCategories =>
      _incomeCategories.map((key, value) => MapEntry(key, value.subCategories));

  bool categoryActive(String main) {
    final node = _expenseCategories[main] ?? _incomeCategories[main];
    return node?.active ?? true;
  }

  void toggleCategoryActive(String main, bool value) {
    if (_expenseCategories.containsKey(main)) {
      _expenseCategories[main]!.active = value;
    }
    if (_incomeCategories.containsKey(main)) {
      _incomeCategories[main]!.active = value;
    }
    unawaited(_persistCategories());
    notifyListeners();
  }

  Future<void> addCategory({
    required bool income,
    required String main,
    String? subCategory,
    bool active = true,
  }) async {
    final target = income ? _incomeCategories : _expenseCategories;
    final existing = target[main];
    if (existing == null) {
      target[main] = CategoryNode(
        name: main,
        subCategories: subCategory != null ? [subCategory] : <String>[],
        active: active,
      );
    } else {
      if (subCategory != null && !existing.subCategories.contains(subCategory)) {
        existing.subCategories.add(subCategory);
      }
      existing.active = active;
    }
    await _persistCategories();
    notifyListeners();
  }

  Future<void> removeSubCategory({required bool income, required String main, required String sub}) async {
    final target = income ? _incomeCategories : _expenseCategories;
    final node = target[main];
    if (node == null) return;
    node.subCategories.remove(sub);
    await _persistCategories();
    notifyListeners();
  }

  Future<void> addAccount({
    required String name,
    required String type,
    required String currency,
    int? cutoffDay,
    int? dueDay,
    double? limit,
    double initialBalance = 0,
  }) async {
    _recordSnapshot();
    final account = FinanceAccount(
      id: _uuid.v4(),
      name: name,
      type: type,
      currency: currency,
      cutoffDay: cutoffDay,
      dueDay: dueDay,
      limit: limit,
      balance: initialBalance,
    );
    _accounts.add(account);
    await _accountsBox.put(account.id, account.toMap());
    notifyListeners();
    _scheduleSync();
  }

  Future<void> removeAccount(String id) async {
    _recordSnapshot();
    _accounts.removeWhere((element) => element.id == id);
    await _accountsBox.delete(id);
    final toRemove = _transactions.where((element) => element.accountId == id).toList();
    for (final record in toRemove) {
      await _transactionsBox.delete(record.id);
    }
    _transactions.removeWhere((element) => element.accountId == id);
    notifyListeners();
    _scheduleSync();
  }

  Future<void> addTransaction({
    required String accountId,
    required TransactionKind kind,
    required DateTime date,
    required String description,
    required double amount,
    String? currency,
    String? mainCategory,
    String? subCategory,
    int installments = 1,
    bool paid = false,
    String? note,
  }) async {
    final account = _accounts.firstWhereOrNull((element) => element.id == accountId);
    if (account == null) return;
    _recordSnapshot();
    final statement = _calculateStatement(date, account.cutoffDay);
    final firstInstallment = _calculateFirstInstallment(statement, account.dueDay);
    final lastInstallment = DateTime(
      firstInstallment.year,
      firstInstallment.month + max(0, installments - 1),
      firstInstallment.day,
    );
    final record = TransactionRecord(
      id: _uuid.v4(),
      accountId: accountId,
      kind: kind,
      date: date,
      description: description,
      amount: amount,
      currency: currency ?? account.currency,
      statementMonth: statement.month,
      statementYear: statement.year,
      status: paid ? TransactionStatus.paid : TransactionStatus.unpaid,
      mainCategory: mainCategory,
      subCategory: subCategory,
      note: note,
      installments: installments,
      firstInstallment: firstInstallment,
      lastInstallment: lastInstallment,
    );
    _transactions.add(record);
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    if (kind == TransactionKind.income) {
      account.balance += amount;
    } else if (kind == TransactionKind.expense) {
      account.balance -= amount;
    }
    await _accountsBox.put(account.id, account.toMap());
    await _transactionsBox.put(record.id, record.toMap());
    notifyListeners();
    _scheduleSync();
  }

  Future<void> removeTransaction(String id) async {
    final index = _transactions.indexWhere((element) => element.id == id);
    if (index == -1) return;
    _recordSnapshot();
    final removed = _transactions.removeAt(index);
    await _transactionsBox.delete(id);
    final account = _accounts.firstWhereOrNull((element) => element.id == removed.accountId);
    if (account != null) {
      if (removed.kind == TransactionKind.income) {
        account.balance -= removed.amount;
      } else if (removed.kind == TransactionKind.expense) {
        account.balance += removed.amount;
      }
      await _accountsBox.put(account.id, account.toMap());
    }
    notifyListeners();
    _scheduleSync();
  }

  Future<void> togglePaid(String transactionId) async {
    final index = _transactions.indexWhere((element) => element.id == transactionId);
    if (index == -1) return;
    _recordSnapshot();
    final record = _transactions[index];
    final updated = TransactionRecord(
      id: record.id,
      accountId: record.accountId,
      kind: record.kind,
      date: record.date,
      description: record.description,
      amount: record.amount,
      currency: record.currency,
      statementMonth: record.statementMonth,
      statementYear: record.statementYear,
      status: record.isPaid ? TransactionStatus.unpaid : TransactionStatus.paid,
      mainCategory: record.mainCategory,
      subCategory: record.subCategory,
      note: record.note,
      installments: record.installments,
      firstInstallment: record.firstInstallment,
      lastInstallment: record.lastInstallment,
    );
    _transactions[index] = updated;
    await _transactionsBox.put(updated.id, updated.toMap());
    _scheduleSync();
    notifyListeners();
  }

  Map<String, AccountSpending> accountSpending({
    bool includePaid = true,
    bool includePending = true,
  }) {
    final Map<String, AccountSpending> result = {};
    for (final account in _accounts) {
      final expensesForAccount = expenses.where((element) => element.accountId == account.id);
      double paidTotal = 0;
      double pendingTotal = 0;
      for (final tx in expensesForAccount) {
        if (tx.isPaid) {
          paidTotal += tx.amount;
        } else {
          pendingTotal += tx.amount;
        }
      }
      result[account.id] = AccountSpending(
        account: account,
        paid: includePaid ? paidTotal : 0,
        pending: includePending ? pendingTotal : 0,
      );
    }
    return result;
  }

  List<MapEntry<String, double>> topExpenseCategories({int take = 5}) {
    final Map<String, double> totals = {};
    for (final tx in expenses) {
      final key = tx.mainCategory ?? 'Diğer';
      totals[key] = (totals[key] ?? 0) + tx.amount;
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(take).toList();
  }

  List<TransactionRecord> recentTransactions({int take = 6}) {
    return _transactions.take(take).toList();
  }

  List<TransactionRecord> upcomingPayments({int take = 5}) {
    final now = DateTime.now();
    final items = unpaidExpenses.toList()
      ..sort((a, b) => a.firstInstallment.compareTo(b.firstInstallment));
    return items
        .where((element) => element.firstInstallment.isAfter(now.subtract(const Duration(days: 1))))
        .take(take)
        .toList();
  }

  Map<DateTime, double> installmentMatrix(int months) {
    final DateTime start = DateTime(DateTime.now().year, DateTime.now().month, 1);
    final Map<DateTime, double> totals = {
      for (int i = 0; i < months; i++)
        DateTime(start.year, start.month + i, 1): 0,
    };
    for (final tx in expenses) {
      if (tx.installments <= 1) {
        final monthKey = DateTime(tx.firstInstallment.year, tx.firstInstallment.month, 1);
        if (totals.containsKey(monthKey)) {
          totals[monthKey] = (totals[monthKey] ?? 0) + tx.amount;
        }
        continue;
      }
      final monthlyAmount = tx.amount / tx.installments;
      for (int i = 0; i < tx.installments; i++) {
        final monthKey = DateTime(tx.firstInstallment.year, tx.firstInstallment.month + i, 1);
        if (totals.containsKey(monthKey)) {
          totals[monthKey] = (totals[monthKey] ?? 0) + monthlyAmount;
        }
      }
    }
    return totals;
  }

  String formatCurrency(double value) {
    final format = NumberFormat.currency(locale: 'tr_TR', symbol: '₺');
    return format.format(value);
  }

  Map<String, double> totalsByCategory(
    TransactionKind kind, {
    DateTime? start,
    DateTime? end,
  }) {
    final DateTime rangeStart = start ?? DateTime(1970, 1, 1);
    final DateTime rangeEnd = end ?? DateTime.now();
    final Iterable<TransactionRecord> source =
        kind == TransactionKind.income ? incomes : expenses;
    final Map<String, double> totals = {};
    for (final tx in source) {
      if (tx.date.isBefore(rangeStart) || tx.date.isAfter(rangeEnd)) {
        continue;
      }
      final key = tx.mainCategory ?? (kind == TransactionKind.income ? 'Diğer Gelir' : 'Diğer Gider');
      totals[key] = (totals[key] ?? 0) + tx.amount;
    }
    return totals;
  }

  List<CategorySuggestion> topExpenseCategories({int limit = 3}) {
    final totals = totalsByCategory(TransactionKind.expense);
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(limit).map(
      (entry) => CategorySuggestion(
        main: entry.key,
        sub: null,
        confidence: entry.value,
      ),
    ).toList();
  }

  List<TransactionRecord> upcomingPaymentsWithin({int days = 30}) {
    final now = DateTime.now();
    final end = now.add(Duration(days: days));
    final upcoming = unpaidExpenses
        .where((tx) => !tx.firstInstallment.isAfter(end))
        .where((tx) => !tx.firstInstallment.isBefore(now.subtract(const Duration(days: 1))))
        .toList()
      ..sort((a, b) => a.firstInstallment.compareTo(b.firstInstallment));
    return upcoming;
  }

  List<TransactionRecord> transactionsForMonth(DateTime month, {TransactionKind? kind}) {
    final DateTime start = DateTime(month.year, month.month, 1);
    final DateTime end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
    Iterable<TransactionRecord> list = _transactions;
    if (kind != null) {
      list = list.where((tx) => tx.kind == kind);
    }
    return list
        .where((tx) => !tx.date.isBefore(start) && !tx.date.isAfter(end))
        .toList();
  }

  Map<String, double> monthlySummary(DateTime month) {
    final incomesForMonth =
        transactionsForMonth(month, kind: TransactionKind.income)
            .fold<double>(0, (value, element) => value + element.amount);
    final expensesForMonth =
        transactionsForMonth(month, kind: TransactionKind.expense)
            .fold<double>(0, (value, element) => value + element.amount);
    return {
      'income': incomesForMonth,
      'expense': expensesForMonth,
      'net': incomesForMonth - expensesForMonth,
    };
  }

  List<CategorySuggestion> suggestCategoriesFor(
    String description,
    TransactionKind kind, {
    int limit = 5,
  }) {
    final lower = description.toLowerCase();
    final Map<String, CategoryNode> target =
        kind == TransactionKind.income ? _incomeCategories : _expenseCategories;
    final List<CategorySuggestion> suggestions = [];
    for (final entry in target.entries) {
      final main = entry.key;
      final node = entry.value;
      final lowerMain = main.toLowerCase();
      if (lower.contains(lowerMain)) {
        suggestions.add(
          CategorySuggestion(
            main: main,
            sub: node.subCategories.isNotEmpty ? node.subCategories.first : null,
            confidence: 0.6,
          ),
        );
      }
      for (final sub in node.subCategories) {
        final lowerSub = sub.toLowerCase();
        if (lowerSub.isNotEmpty && lower.contains(lowerSub)) {
          suggestions.add(
            CategorySuggestion(
              main: main,
              sub: sub,
              confidence: 0.95,
            ),
          );
        }
      }
    }
    suggestions.sort((a, b) => b.confidence.compareTo(a.confidence));
    final Map<String, CategorySuggestion> unique = {};
    for (final suggestion in suggestions) {
      final key = '${suggestion.main}::${suggestion.sub ?? ''}';
      unique.putIfAbsent(key, () => suggestion);
      if (unique.length >= limit) break;
    }
    return unique.values.take(limit).toList();
  }

  Future<void> changeCurrency(String currency) async {
    _defaultCurrency = currency;
    await _settingsBox.put('currency', currency);
    notifyListeners();
    _scheduleSync();
  }

  bool get canUndo => _undoStack.isNotEmpty;
  bool get canRedo => _redoStack.isNotEmpty;

  void _recordSnapshot() {
    _undoStack.add(_FinanceSnapshot(
      accounts: _accounts.map((e) => {...e.toMap(), 'id': e.id}).toList(),
      transactions: _transactions.map((e) => {...e.toMap(), 'id': e.id}).toList(),
    ));
    if (_undoStack.length > 20) {
      _undoStack.removeAt(0);
    }
    _redoStack.clear();
  }

  Future<void> undo() async {
    if (_undoStack.isEmpty) return;
    final snapshot = _undoStack.removeLast();
    _redoStack.add(_FinanceSnapshot(
      accounts: _accounts.map((e) => {...e.toMap(), 'id': e.id}).toList(),
      transactions: _transactions.map((e) => {...e.toMap(), 'id': e.id}).toList(),
    ));
    await _restoreSnapshot(snapshot);
  }

  Future<void> redo() async {
    if (_redoStack.isEmpty) return;
    final snapshot = _redoStack.removeLast();
    _undoStack.add(_FinanceSnapshot(
      accounts: _accounts.map((e) => {...e.toMap(), 'id': e.id}).toList(),
      transactions: _transactions.map((e) => {...e.toMap(), 'id': e.id}).toList(),
    ));
    await _restoreSnapshot(snapshot);
  }

  Future<void> _restoreSnapshot(_FinanceSnapshot snapshot) async {
    await _accountsBox.clear();
    await _transactionsBox.clear();
    _accounts = [
      for (final map in snapshot.accounts)
        FinanceAccount.fromMap(map['id'] as String, map)
    ];
    _transactions = [
      for (final map in snapshot.transactions)
        TransactionRecord.fromMap(map['id'] as String, map)
    ];
    for (final account in _accounts) {
      await _accountsBox.put(account.id, account.toMap());
    }
    for (final tx in _transactions) {
      await _transactionsBox.put(tx.id, tx.toMap());
    }
    _transactions.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  void _scheduleSync() {
    if (!_syncEnabled) return;
    if (SupabaseService.client == null) return;
    _syncDebounce?.cancel();
    _syncDebounce = Timer(const Duration(seconds: 2), () {
      unawaited(_pushToSupabase());
    });
  }

  Future<void> setSyncEnabled(bool enabled) async {
    if (_syncEnabled == enabled) return;
    _syncEnabled = enabled;
    await _settingsBox.put('sync_enabled', enabled);
    if (!enabled) {
      _syncDebounce?.cancel();
    } else {
      await _pullFromSupabase();
      await _pushToSupabase();
    }
    notifyListeners();
  }

  Future<void> setProfileId(String? id) async {
    _profileId = (id != null && id.isNotEmpty) ? id : null;
    await _settingsBox.put('profile_id', _profileId);
    if (_syncEnabled) {
      await _pullFromSupabase();
    }
    notifyListeners();
  }

  Future<void> syncNow() async {
    if (!_syncEnabled) return;
    await _pullFromSupabase();
    await _pushToSupabase();
  }

  Future<void> _pushToSupabase() async {
    if (!_syncEnabled) return;
    final client = SupabaseService.client;
    if (client == null) return;
    if (_syncInProgress) return;
    _syncInProgress = true;
    final profile = profileId;
    try {
      await client.from('finance_accounts').delete().eq('profile_id', profile);
      if (_accounts.isNotEmpty) {
        final payload = [
          for (final account in _accounts)
            {
              'id': account.id,
              'profile_id': profile,
              'name': account.name,
              'type': account.type,
              'currency': account.currency,
              'cutoff_day': account.cutoffDay,
              'due_day': account.dueDay,
              'limit': account.limit,
              'balance': account.balance,
            }
        ];
        await client.from('finance_accounts').upsert(payload);
      }

      await client.from('finance_transactions').delete().eq('profile_id', profile);
      if (_transactions.isNotEmpty) {
        final payload = [
          for (final tx in _transactions)
            {
              'id': tx.id,
              'profile_id': profile,
              'account_id': tx.accountId,
              'kind': tx.kind.name,
              'date': tx.date.toIso8601String(),
              'description': tx.description,
              'amount': tx.amount,
              'currency': tx.currency,
              'statement_month': tx.statementMonth,
              'statement_year': tx.statementYear,
              'status': tx.status.name,
              'main_category': tx.mainCategory,
              'sub_category': tx.subCategory,
              'note': tx.note,
              'installments': tx.installments,
              'first_installment': tx.firstInstallment.toIso8601String(),
              'last_installment': tx.lastInstallment.toIso8601String(),
            }
        ];
        await client.from('finance_transactions').upsert(payload);
      }

      _lastSync = DateTime.now();
      await _settingsBox.put('last_sync', _lastSync!.toIso8601String());
    } catch (error) {
      debugPrint('Supabase sync push failed: $error');
    } finally {
      _syncInProgress = false;
    }
  }

  Future<void> _pullFromSupabase() async {
    final client = SupabaseService.client;
    if (client == null) return;
    final profile = profileId;
    try {
      final remoteAccountsRaw = await client
          .from('finance_accounts')
          .select()
          .eq('profile_id', profile);

      final remoteTransactionsRaw = await client
          .from('finance_transactions')
          .select()
          .eq('profile_id', profile);

      final remoteAccounts =
          (remoteAccountsRaw as List<dynamic>).cast<Map<String, dynamic>>();
      final remoteTransactions =
          (remoteTransactionsRaw as List<dynamic>).cast<Map<String, dynamic>>();

      if (remoteAccounts.isEmpty && remoteTransactions.isEmpty) {
        return;
      }

      await _accountsBox.clear();
      await _transactionsBox.clear();

      _accounts = [
        for (final map in remoteAccounts)
          FinanceAccount(
            id: map['id'] as String,
            name: map['name'] as String? ?? '',
            type: map['type'] as String? ?? 'Bank',
            currency: map['currency'] as String? ?? _defaultCurrency,
            cutoffDay: map['cutoff_day'] as int?,
            dueDay: map['due_day'] as int?,
            limit: (map['limit'] as num?)?.toDouble(),
            balance: (map['balance'] as num?)?.toDouble() ?? 0,
          ),
      ];
      for (final account in _accounts) {
        await _accountsBox.put(account.id, account.toMap());
      }

      _transactions = [
        for (final map in remoteTransactions)
          TransactionRecord(
            id: map['id'] as String,
            accountId: map['account_id'] as String,
            kind: TransactionKind.values.firstWhere(
              (element) => element.name == (map['kind'] as String? ?? TransactionKind.expense.name),
              orElse: () => TransactionKind.expense,
            ),
            date: DateTime.parse(map['date'] as String),
            description: map['description'] as String? ?? '',
            amount: (map['amount'] as num?)?.toDouble() ?? 0,
            currency: map['currency'] as String? ?? _defaultCurrency,
            statementMonth: map['statement_month'] as int? ?? DateTime.now().month,
            statementYear: map['statement_year'] as int? ?? DateTime.now().year,
            status: TransactionStatus.values.firstWhere(
              (element) => element.name == (map['status'] as String? ?? TransactionStatus.unpaid.name),
              orElse: () => TransactionStatus.unpaid,
            ),
            mainCategory: map['main_category'] as String?,
            subCategory: map['sub_category'] as String?,
            note: map['note'] as String?,
            installments: map['installments'] as int? ?? 1,
            firstInstallment: DateTime.parse(
              (map['first_installment'] as String?) ?? (map['date'] as String),
            ),
            lastInstallment: DateTime.parse(
              (map['last_installment'] as String?) ?? (map['date'] as String),
            ),
          ),
      ];
      for (final tx in _transactions) {
        await _transactionsBox.put(tx.id, tx.toMap());
      }
      _transactions.sort((a, b) => b.date.compareTo(a.date));
      _lastSync = DateTime.now();
      await _settingsBox.put('last_sync', _lastSync!.toIso8601String());
      notifyListeners();
    } catch (error) {
      debugPrint('Supabase sync pull failed: $error');
    }
  }

  DateTime _calculateStatement(DateTime date, int? cutoffDay) {
    if (cutoffDay == null) {
      return DateTime(date.year, date.month, 1);
    }
    if (date.day <= cutoffDay) {
      return DateTime(date.year, date.month, 1);
    }
    final nextMonth = DateTime(date.year, date.month + 1, 1);
    return DateTime(nextMonth.year, nextMonth.month, 1);
  }

  DateTime _calculateFirstInstallment(DateTime statement, int? dueDay) {
    return DateTime(statement.year, statement.month, dueDay ?? 1);
  }

  @override
  void dispose() {
    _syncDebounce?.cancel();
    super.dispose();
  }
}

const Map<String, List<String>> defaultExpenseCategories = {
  'Kira & Konut': [
    'Kira',
    'Ev Kirası',
    'Depozito',
    'Aidat',
    'Emlak Vergisi',
    'Ev Sigortası',
    'Ev tapu',
    'Kira Sigortası',
  ],
  'Faturalar': [
    'Elektrik',
    'Su',
    'Doğalgaz',
    'İnternet',
    'Telefon',
    'TV Abonelikleri',
  ],
  'Alışveriş': [
    'Market',
    'Meyve ve Sebze',
    'Mobilya',
    'Elektronik',
    'Beyaz Eşya',
    'Giyim',
    'Ayakkabı',
    'Kozmetik',
    'Kitap',
    'Kırtasiye',
    'Kuruyemiş',
    'Amazon',
    'Etsy',
    'Ebay',
    'DijitalHarcamalar',
  ],
  'Ulaşım & Araç': [
    'Ulaşım',
    'Taksi',
    'Araç Bakımı',
    'Araç Sigortası',
    'Araç Vergisi',
    'Yakıt',
    'Araç Kredisi',
    'Araç Yıkama',
    'Lastik Degisimi',
  ],
  'Sağlık & Sigorta': [
    'Hastane',
    'İlaç',
    'Diş Tedavisi',
    'Sağlık',
    'Hayat Sigortası',
    'Seyahat Sigortası',
    'Alternatif Tedaviler',
  ],
  'Eğitim & Gelişim': [
    'Medrese',
    'Eğitim',
    'Kurs Ücretleri',
    'Online Eğitim',
    'Özel Dersler',
    'Udemy',
    'Program',
  ],
  'Abonelikler': [
    'Spotify',
    'Netflix',
    'Bulut Depolama',
    'Dijital Kitap ve Filmler',
    'Yazılım Abonelikleri',
  ],
  'Borç & Ödemeler': [
    'Borc',
    'Kredi Kartı Ödemeleri',
    'Tüketici Kredisi',
    'Diğer Borçlar',
  ],
  'Tasarruf & Yatırım': [
    'Tasarruf',
    'Altın',
    'HisseSenedi',
    'Döviz',
    'Yatırım Gelirleri',
    'Emeklilik Planı',
  ],
  'Çocuk & Aile': [
    'Çocuk',
    'Kreş',
    'Çocuk Giysileri',
    'Çocuk Sağlık Harcamaları',
    'Aileye Hediyeler',
  ],
  'Kişisel & Bakım': [
    'KişiselBakım',
    'Cilt Bakımı',
    'Manikür',
    'Kuaför',
    'Saç Boyama',
    'Kozmetik',
  ],
  'Eğlence & Etkinlik': [
    'Gezi',
    'Oyun İçi Satın Alımlar',
    'Tatil',
    'Tur ve Aktiviteler',
    'Eğlence',
    'Sinema',
  ],
  'Özel Günler': [
    'ÖzelGünler',
    'Doğum Günü',
    'Anneler/Babalar Günü',
    'Sevgililer Günü',
    'Nişan',
    'Düğün',
    'Yılbaşı',
  ],
  'Evcil Hayvan & Bahçe': [
    'EvcilHayvanBakımı',
    'Mama',
    'Veteriner',
    'Bahçe Bakımı',
  ],
  'İş & Profesyonel': [
    'iş',
    'İş Yemekleri',
    'Ofis Malzemeleri',
    'Reklam',
    'Vergi',
    'KDV',
  ],
  'Diğer': [
    'Ceza',
    'Mahkeme Masrafları',
    'Noter Ücretleri',
    'Bağışlar',
    'Sadaka',
    'Zekat',
    'Acil Durum Harcamaları',
  ],
};

const Map<String, List<String>> defaultIncomeCategories = {
  'Maaş & Ücretler': [
    'Aylık Maaş',
    'Ek Mesai',
    'Prim',
    'Performans Destek',
  ],
  'Serbest Meslek': [
    'Freelance Proje Gelirleri',
    'Danışmanlık Ücretleri',
    'Tasarım/Yazılım Gelirleri',
    'Hizmet Satış Gelirleri',
  ],
  'Yatırım Gelirleri': [
    'Temettü Gelirleri',
    'Faiz Gelirleri',
    'Kripto Para',
    'Repo Gelirleri',
    'Değer Artış Kazançları',
  ],
  'E-Ticaret': [
    'Amazon FBA Satışları',
    'Amazon FBM Satışları',
    'Amazon Affiliate',
    'Merch by Amazon',
    'eBay Dropshipping',
    'eBay Global Satış Gelirleri',
    'Etsy El Yapımı Ürün Satışı',
    'Etsy Dijital Sanat',
  ],
  'Kira & Passive': [
    'Ev Kirası',
    'Depo Kirası',
    'Franchise Gelirleri',
    'Lisans Gelirleri',
  ],
  'Diğer Gelirler': [
    'Bağış/Sponsorluk',
    'Çekiliş/Piyango Kazançları',
    'Tazminatlar',
    'Nafaka',
    'Sosyal Yardımlar',
  ],
};
