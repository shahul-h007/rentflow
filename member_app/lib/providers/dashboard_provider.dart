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
}
