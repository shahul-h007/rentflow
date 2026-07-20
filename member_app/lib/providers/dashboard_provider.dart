import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class DashboardProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  HouseInfo? _house;
  RentMonth? _currentMonth;
  List<Member> _members = [];
  List<Debt> _debts = [];
  bool _isLoading = false;
  bool _isBusy = false;
  String? _errorMessage;

  HouseInfo? get house => _house;
  RentMonth? get currentMonth => _currentMonth;
  List<Member> get members => _members;
  List<Debt> get debts => _debts;
  bool get isLoading => _isLoading;
  bool get isBusy => _isBusy;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard({bool silent = false}) async {
    if (!silent) {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
    }

    try {
      final json = await _apiService.fetchDashboard();

      // Parse house settings (includes UPI ID, owner name, etc.)
      if (json['house'] != null) {
        _house = HouseInfo.fromJson(json['house']);
      }
      
      if (json['month'] != null) {
        _currentMonth = RentMonth.fromJson(json['month']);
        // Debts come nested inside the month object from the API
        _debts = _currentMonth!.debts;
      } else {
        _currentMonth = null;
        _debts = [];
      }

      if (json['members'] != null) {
        var list = json['members'] as List;
        _members = list.map((m) => Member.fromJson(m)).toList();
      } else {
        _members = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> payRent({
    required String paymentId,
    required int amountPaid,
    required String method,
  }) async {
    _isBusy = true;
    notifyListeners();
    try {
      await _apiService.submitRentPayment(
        paymentId: paymentId,
        amountPaid: amountPaid,
        method: method,
      );
      await loadDashboard(silent: true);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addExpense({
    required String title,
    required int amount,
    required String paidById,
    String? notes,
  }) async {
    if (_currentMonth == null) return false;
    _isBusy = true;
    notifyListeners();
    try {
      await _apiService.addExpense(
        monthId: _currentMonth!.id,
        title: title,
        amount: amount,
        paidById: paidById,
        notes: notes,
      );
      await loadDashboard(silent: true);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> recordSettlement({
    required String debtorId,
    required String creditorId,
    required int amount,
    required String reason,
  }) async {
    _isBusy = true;
    notifyListeners();
    try {
      await _apiService.addSettlement(
        debtorId: debtorId,
        creditorId: creditorId,
        amount: amount,
        reason: reason,
      );
      await loadDashboard(silent: true);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteExpense(String expenseId) async {
    _isBusy = true;
    notifyListeners();
    try {
      await _apiService.deleteExpense(expenseId);
      await loadDashboard(silent: true);
      _isBusy = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll("Exception:", "").trim();
      _isBusy = false;
      notifyListeners();
      return false;
    }
  }
  int getUserTotalOutstanding(String? memberId) {
    if (memberId == null || _currentMonth == null) return 0;
    
    int total = 0;
    
    // Rent Due
    final rentPayment = _currentMonth!.rentPayments.where((p) => p.memberId == memberId).firstOrNull;
    if (rentPayment != null) {
      total += (rentPayment.amountDue - rentPayment.amountPaid);
    }
    
    // Utilities Due
    for (var utility in _currentMonth!.utilities) {
      final utilPayment = utility.payments.where((p) => p.memberId == memberId).firstOrNull;
      if (utilPayment != null) {
        total += (utilPayment.amountDue - utilPayment.amountPaid);
      }
    }
    
    // Debts Due (Settlements owed to others)
    final userDebts = _debts.where((d) => d.debtorId == memberId && d.status != 'SETTLED');
    for (var debt in userDebts) {
      total += (debt.amount - debt.settledAmount);
    }
    
    return total;
  }

  List<Map<String, dynamic>> getRecentActivity(String? memberId) {
    if (memberId == null || _currentMonth == null) return [];
    
    List<Map<String, dynamic>> activities = [];
    
    // Add Rent Payments
    final rentPayment = _currentMonth!.rentPayments.where((p) => p.memberId == memberId).firstOrNull;
    if (rentPayment != null) {
      for (var tx in rentPayment.transactions) {
        activities.add({
          'id': tx.id,
          'title': 'Monthly Rent Payment',
          'subtitle': 'Apartment Rent',
          'amount': tx.amount,
          'date': tx.paidAt,
          'type': 'RENT',
          'status': tx.status == 'APPROVED' ? 'SETTLED' : tx.status,
        });
      }
      if (rentPayment.transactions.isEmpty && rentPayment.status == 'PENDING') {
         activities.add({
          'id': 'rent_due',
          'title': 'Monthly Rent Payment',
          'subtitle': 'Apartment Rent',
          'amount': rentPayment.amountDue - rentPayment.amountPaid,
          'date': _currentMonth!.startsOn,
          'type': 'RENT',
          'status': 'PENDING',
        });
      }
    }

    // Add Expenses
    for (var expense in _currentMonth!.expenses) {
      // If user is involved in the split or paid it
      final isPayer = expense.paidById == memberId;
      final split = expense.splits.where((s) => s.memberId == memberId).firstOrNull;
      
      if (isPayer || split != null) {
        activities.add({
          'id': expense.id,
          'title': expense.title,
          'subtitle': 'Split with Roommates',
          'amount': split != null ? split.amount : expense.amount, // amount user owes or paid
          'date': expense.createdAt,
          'type': 'EXPENSE',
          'status': 'PENDING', // Expenses don't have individual settled status in the model directly, usually handled by debts
        });
      }
    }

    // Sort by date descending
    activities.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    return activities;
  }
}
