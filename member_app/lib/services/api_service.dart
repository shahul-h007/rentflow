import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final String baseUrl = "https://rentflow-sooty.vercel.app";
  final SupabaseClient _supabase = Supabase.instance.client;

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<String?> _getAccessToken() async {
    final session = _supabase.auth.currentSession;
    return session?.accessToken;
  }

  Future<Map<String, dynamic>> _get(String path) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("User is not signed in.");

    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? "Failed to fetch data from server");
    }
    return data;
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> body) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("User is not signed in.");

    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(data['error'] ?? "Failed to save record");
    }
    return data;
  }

  Future<Map<String, dynamic>> _patch(String path, Map<String, dynamic> body) async {
    final token = await _getAccessToken();
    if (token == null) throw Exception("User is not signed in.");

    final response = await http.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body),
    );

    final data = jsonDecode(response.body);
    if (response.statusCode != 200) {
      throw Exception(data['error'] ?? "Failed to update record");
    }
    return data;
  }

  // API Methods
  Future<Map<String, dynamic>> fetchDashboard() async {
    return await _get('/api/dashboard');
  }

  Future<void> syncSession() async {
    await _post('/api/auth/session', {});
  }

  Future<void> markRentPaid({
    required String paymentId,
    required int amountPaid,
    required String method,
  }) async {
    await _patch(
      '/api/rent-payments/$paymentId',
      {
        'amountPaid': amountPaid,
        'method': method,
      },
    );
  }

  Future<void> addExpense({
    required String monthId,
    required String title,
    required int amount,
    required String paidById,
    String? notes,
  }) async {
    await _post(
      '/api/expenses',
      {
        'monthId': monthId,
        'title': title,
        'amount': amount,
        'paidById': paidById,
        'notes': notes,
      },
    );
  }

  Future<void> addSettlement({
    required String debtorId,
    required String creditorId,
    required int amount,
    required String reason,
  }) async {
    await _post(
      '/api/debts',
      {
        'debtorId': debtorId,
        'creditorId': creditorId,
        'amount': amount,
        'reason': reason,
      },
    );
  }
}
