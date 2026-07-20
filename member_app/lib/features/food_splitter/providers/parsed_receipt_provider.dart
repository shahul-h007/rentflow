import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/models/parsed_receipt.dart';

class ParsedReceiptNotifier extends Notifier<ParsedReceipt?> {
  @override
  ParsedReceipt? build() => null;
  
  void setReceipt(ParsedReceipt? receipt) {
    state = receipt;
  }
}

final parsedReceiptProvider = NotifierProvider<ParsedReceiptNotifier, ParsedReceipt?>(
  () => ParsedReceiptNotifier(),
);
