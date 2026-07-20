import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repository/receipt_repository_impl.dart';
import '../domain/repositories/receipt_repository.dart';

final receiptRepositoryProvider = Provider<ReceiptRepository>((ref) {
  return ReceiptRepositoryImpl();
});
