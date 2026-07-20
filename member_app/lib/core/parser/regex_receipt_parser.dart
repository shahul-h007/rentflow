import 'package:uuid/uuid.dart';
import '../../features/food_splitter/domain/models/parsed_receipt.dart';
import 'extractors/merchant_extractor.dart';
import 'extractors/receipt_number_extractor.dart';
import 'extractors/date_extractor.dart';
import 'extractors/item_extractor.dart';
import 'extractors/gst_extractor.dart';
import 'extractors/total_extractor.dart';
import 'extractors/text_normalizer.dart';
import 'extractors/line_tokenizer.dart';

class RegexReceiptParser {
  static final _uuid = const Uuid();

  static ParsedReceipt parse(String rawOcrText) {
    final normalized = TextNormalizer.normalize(rawOcrText);
    final lines = LineTokenizer.tokenize(normalized);

    final merchant = MerchantExtractor.extract(lines);
    final receiptNumber = ReceiptNumberExtractor.extract(lines);
    final date = DateExtractor.extract(lines);
    
    final items = ItemExtractor.extract(lines);
    final gst = GSTExtractor.extract(lines);
    final total = TotalExtractor.extract(lines);

    // Confidence Calculation Logic
    double confidence = 100.0;
    if (merchant == null) confidence -= 10.0;
    if (total == null) confidence -= 20.0;
    if (items.isEmpty) confidence -= 30.0;

    return ParsedReceipt(
      id: _uuid.v4(),
      merchant: merchant,
      receiptNumber: receiptNumber,
      date: date,
      items: items,
      gst: gst,
      grandTotal: total,
      overallConfidence: confidence,
    );
  }
}
