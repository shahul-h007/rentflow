import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/repositories/receipt_repository.dart';
import '../../domain/models/parsed_receipt.dart';
import '../../domain/models/expense_assignment.dart';
import '../../../../core/calculation/calculation_engine.dart';

class ReceiptRepositoryImpl implements ReceiptRepository {
  @override
  Future<ParsedReceipt> scanAndParseReceipt(File image) async {
    // TODO: Integrate with backend API Phase 9
    // For now, return a mock or delay
    await Future.delayed(const Duration(seconds: 2));
    throw UnimplementedError('API not connected yet');
  }

  @override
  Future<void> saveExpense({
    required ParsedReceipt receipt,
    required List<ExpenseAssignment> assignments,
  }) async {
    // 1. Calculate final amounts so the backend doesn't have to duplicate the logic
    final calcResult = CalculationEngine.calculate(receipt: receipt, assignments: assignments);
    if (!calcResult.isValid) throw Exception('Calculation error');

    // 2. Prepare Payload
    final payload = {
      // Hardcoded for V1 MVP
      'houseId': 'temp_house_id', 
      'scannedById': 'temp_member_id',
      
      'merchant': receipt.merchant,
      'receiptNumber': receipt.receiptNumber,
      'date': receipt.date, // Ideally ISO
      'subtotal': receipt.subtotal ?? 0,
      'gst': receipt.gst ?? 0,
      'serviceCharge': receipt.serviceCharge ?? 0,
      'deliveryCharge': receipt.deliveryCharge ?? 0,
      'tip': receipt.tip ?? 0,
      'discount': receipt.discount ?? 0,
      'roundOff': receipt.roundOff ?? 0,
      'grandTotal': receipt.grandTotal ?? 0,
      'rawOcrText': 'V1 offline OCR text',
      
      'items': receipt.items.map((i) => i.toJson()).toList(),
      'assignments': assignments.map((a) => a.toJson()).toList(),
      
      'calculations': calcResult.members.map((m) => {
        'memberId': m.memberId,
        'foodAmount': m.food,
        'gstAmount': m.gst,
        'discountAmount': m.discount,
        'serviceAmount': m.serviceCharge,
        'deliveryAmount': m.delivery,
        'tipAmount': m.tip,
        'roundOffAmount': m.roundOff,
        'finalAmount': m.finalAmount,
      }).toList(),
    };

    // 3. Post to Next.js Backend
    final response = await http.post(
      Uri.parse('https://rentflow-sooty.vercel.app/api/food-splitter/save'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(payload),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to save receipt: ${response.body}');
    }
  }

  @override
  Future<List<ParsedReceipt>> getReceiptHistory() async {
    // 1. Get houseId (Hardcoded for MVP)
    const houseId = 'temp_house_id';
    
    // 2. Fetch from Next.js Backend
    final response = await http.get(
      Uri.parse('https://rentflow-sooty.vercel.app/api/food-splitter/history?houseId=$houseId'),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to load history');
    }

    final data = jsonDecode(response.body);
    final receiptsData = data['receipts'] as List;

    // 3. Map back to domain model (basic mapping for now)
    return receiptsData.map((r) => ParsedReceipt(
      id: r['id'],
      merchant: r['merchant'] ?? 'Unknown',
      date: r['createdAt'], // Using created_at for display if actual date is missing
      grandTotal: (r['grandTotal'] as num?)?.toDouble() ?? 0.0,
      items: [], // Details screen can fetch full items if needed later, or we map them here
    )).toList();
  }
}
