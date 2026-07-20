import 'dart:io';
import '../models/parsed_receipt.dart';
import '../models/expense_assignment.dart';

abstract class ReceiptRepository {
  /// Uploads the image and returns a scanned & parsed receipt from the backend
  Future<ParsedReceipt> scanAndParseReceipt(File image);

  /// Saves the final edited receipt and assignments to the backend
  Future<void> saveExpense({
    required ParsedReceipt receipt,
    required List<ExpenseAssignment> assignments,
  });

  /// Fetches history of food expenses
  Future<List<ParsedReceipt>> getReceiptHistory();
}
