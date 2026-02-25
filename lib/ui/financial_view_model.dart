import 'package:flutter/foundation.dart';
import 'dart:async';
import '../data/repository/grooming_repository.dart';
import '../data/entity/expense.dart';
import '../data/entity/deposit_entities.dart';
import '../data/entity/session.dart';
import '../data/entity/hotel_entities.dart';

class FinancialViewModel extends ChangeNotifier {
  final GroomingRepository _repository;

  List<Expense> _expenses = [];
  List<OwnerDeposit> _deposits = [];
  bool _isLoading = true;

  // Report Data
  double _monthlyIncome = 0.0;
  double _monthlyExpense = 0.0;
  int _sessionsCount = 0;

  DateTime _currentMonth = DateTime.now();
  StreamSubscription? _hotelSubscription;
  StreamSubscription? _sessionSubscription;
  StreamSubscription? _expenseSubscription;

  StreamSubscription? _dataRestoredSubscription;

  FinancialViewModel(this._repository) {
    _init();
  }

  List<Expense> get expenses => _expenses;
  List<OwnerDeposit> get deposits => _deposits;
  double get monthlyIncome => _monthlyIncome;
  double get monthlyExpense => _monthlyExpense;
  int get sessionsCount => _sessionsCount;
  bool get isLoading => _isLoading;
  DateTime get currentMonth => _currentMonth;

  // Cat Lookup
  Map<int, String> _catNames = {};
  String getCatName(int catId) => _catNames[catId] ?? 'Unknown Cat';

  void _loadCatNames() {
    _repository.getAllCats().listen((cats) {
      _catNames = {for (var c in cats) c.catId: c.catName};
      notifyListeners();
    });
  }

  void _init() {
    _loadAllDeposits();
    _loadCatNames();
    _loadMonthData(_currentMonth);
    
    _hotelSubscription = _repository.onHotelBookingChanged.listen((_) {
      _loadMonthData(_currentMonth);
    });

    _sessionSubscription = _repository.onSessionChanged.listen((_) {
      _loadMonthData(_currentMonth);
    });

    _expenseSubscription = _repository.onExpenseChanged.listen((_) {
      _loadMonthData(_currentMonth);
    });
    
    _dataRestoredSubscription = _repository.onDataRestored.listen((_) {
      _loadAllDeposits();
      _loadCatNames();
      _loadMonthData(_currentMonth);
    });
  }
  
  @override
  void dispose() {
    _hotelSubscription?.cancel();
    _sessionSubscription?.cancel();
    _expenseSubscription?.cancel();
    _dataRestoredSubscription?.cancel();
    super.dispose();
  }

  void setMonth(DateTime month) {
    _currentMonth = month;
    _loadMonthData(month);
  }

  void _loadAllDeposits() {
    _repository.getAllDeposits().listen((list) {
      _deposits = list;
      notifyListeners();
    });
  }

  // Detailed Data
  List<Session> _monthlySessions = [];
  List<HotelBooking> _monthlyHotelBookings = [];

  // Computed Properties
  double get groomingIncome => _monthlySessions.fold(0.0, (sum, s) => sum + s.totalCost);
  double get hotelIncome => _monthlyHotelBookings.fold(0.0, (sum, b) => sum + b.totalCost);
  
  List<dynamic> get allTransactions {
    final List<dynamic> all = [..._monthlySessions, ..._monthlyHotelBookings];
    all.sort((a, b) {
      final timeA = a is Session ? a.timestamp : (a as HotelBooking).checkOutDate;
      final timeB = b is Session ? b.timestamp : (b as HotelBooking).checkOutDate;
      return timeB.compareTo(timeA); // Descending
    });
    return all;
  }

  void _loadMonthData(DateTime date) {
    _isLoading = true;
    notifyListeners();

    final start = DateTime(date.year, date.month, 1).millisecondsSinceEpoch;
    final end = DateTime(date.year, date.month + 1, 0, 23, 59, 59).millisecondsSinceEpoch;

    // Load Expenses
    _repository.getExpensesByMonth(start, end).listen((list) {
      _expenses = list;
      _monthlyExpense = list.fold(0.0, (sum, e) => sum + e.amount);
      notifyListeners();
    });

    // Load Sessions (Grooming Income)
    _repository.getSessionsByDateRange(start, end).listen((list) {
      _monthlySessions = list;
      _updateTotalIncome();
    });

    // Load Hotel Bookings (Hotel Income)
    _repository.getCompletedHotelBookings(start, end).listen((list) {
      _monthlyHotelBookings = list;
      _updateTotalIncome();
    });
    
    // Load Sessions Count (for stats if needed)
    _repository.getSessionsCountByDateRange(start, end).listen((val) {
      _sessionsCount = val;
      notifyListeners();
    });
  }

  void _updateTotalIncome() {
    _monthlyIncome = groomingIncome + hotelIncome;
    _isLoading = false;
    notifyListeners();
  }

  // ─── Expense Management ───────────────────────────────────────────────────

  Future<void> addExpense(String description, double amount, String category, int date) async {
    final expense = Expense(
      note: description,
      amount: amount,
      category: category,
      date: date,
    );
    await _repository.insertExpense(expense);
    _loadMonthData(_currentMonth); // Refresh data
  }

  Future<void> deleteExpense(Expense expense) async {
    await _repository.deleteExpense(expense);
    _loadMonthData(_currentMonth); // Refresh data
  }

  // ─── Deposit Management ───────────────────────────────────────────────────

  Future<void> topUpDeposit(String phone, String name, double amount, String notes) async {
    final existing = await _repository.getDeposit(phone);
    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing != null) {
      final newBalance = existing.balance + amount;
      await _repository.updateDeposit(existing.copyWith(balance: newBalance, lastUpdated: now));
    } else {
      await _repository.insertDeposit(OwnerDeposit(
        ownerPhone: phone,
        ownerName: name,
        balance: amount,
        lastUpdated: now,
      ));
    }

    await _repository.insertDepositTransaction(DepositTransaction(
      ownerPhone: phone,
      amount: amount,
      type: TransactionType.topup,
      notes: notes,
      timestamp: now,
    ));

    _loadAllDeposits();
  }

  Future<void> deductDeposit(String phone, double amount, String notes, int? refId, {TransactionType transactionType = TransactionType.adjustment}) async {
    final existing = await _repository.getDeposit(phone);
    if (existing == null) throw Exception('Deposit account not found');

    if (existing.balance < amount) throw Exception('Insufficient balance');

    final now = DateTime.now().millisecondsSinceEpoch;
    final newBalance = existing.balance - amount;
    
    await _repository.updateDeposit(existing.copyWith(balance: newBalance, lastUpdated: now));
    
    await _repository.insertDepositTransaction(DepositTransaction(
      ownerPhone: phone,
      amount: -amount, // Negative for deduction
      type: transactionType,
      referenceId: refId,
      notes: notes,
      timestamp: now,
    ));

    _loadAllDeposits();
  }

  Stream<List<DepositTransaction>> getTransactions(String phone) {
    return _repository.getDepositTransactions(phone);
  }

  Future<double> getDepositPaidForSession(int sessionId) async {
    final txns = await _repository.getDepositTransactionsForRef(sessionId);
    double total = 0.0;
    for (final t in txns) {
      total += t.amount.abs();
    }
    return total;
  }

  Future<void> adjustBalance(String phone, double newBalance, String notes) async {
    final existing = await _repository.getDeposit(phone);
    if (existing == null) return;
    final now = DateTime.now().millisecondsSinceEpoch;
    final diff = newBalance - existing.balance;

    await _repository.updateDeposit(existing.copyWith(balance: newBalance, lastUpdated: now));
    await _repository.insertDepositTransaction(DepositTransaction(
      ownerPhone: phone,
      amount: diff,
      type: TransactionType.adjustment,
      notes: notes.isEmpty ? 'Penyesuaian saldo' : notes,
      timestamp: now,
    ));

    _loadAllDeposits();
  }

  Future<void> deleteDeposit(String phone) async {
    final existing = await _repository.getDeposit(phone);
    if (existing == null) return;
    await _repository.deleteDepositTransactions(phone);
    await _repository.deleteDeposit(existing);
    _loadAllDeposits();
  }
}
