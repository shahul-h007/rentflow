import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';
import '../models/models.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final SupabaseClient _supabase = Supabase.instance.client;

  UserAccount? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserAccount? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _supabase.auth.currentSession != null;

  AuthProvider() {
    _supabase.auth.onAuthStateChange.listen((data) {
      if (data.session == null) {
        _currentUser = null;
        notifyListeners();
      } else {
        _loadLocalUser();
      }
    });
    if (isAuthenticated) {
      _loadLocalUser();
    }
  }

  Future<void> _loadLocalUser() async {
    try {
      final data = await _apiService.fetchDashboard();
      if (data['account'] != null) {
        _currentUser = UserAccount.fromJson(data['account']);
      }
    } catch (e) {
      // User account is not synced or metadata fetch failed
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Authenticate with Supabase
      final response = await _supabase.auth.signInWithPassword(
        email: email.trim(),
        password: password,
      );

      if (response.user == null) {
        throw Exception("Failed to sign in. Please verify your credentials.");
      }

      // 2. Synchronize the session to Next.js Postgres DB
      await _apiService.syncSession();

      // 3. Fetch dashboard user info to load state
      await _loadLocalUser();

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (error) {
      _errorMessage = error.toString().replaceAll("Exception:", "").trim();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
    _currentUser = null;
    notifyListeners();
  }
}
