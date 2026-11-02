import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:re_turn_app/models/voucher.dart';

const List<String> kVoucherCsvHeader = [
  'id',
  'barcode',
  'deposit_value',
  'store_name',
  'store_location',
  'date_created',
  'receipt_date_time',
  'is_used',
  'used_date',
  'latitude',
  'longitude',
];

/// Escapes one CSV cell. Quotes fields containing commas, quotes or newlines,
/// and prefixes formula-like text (=, +, -, @) so spreadsheets do not run it.
String csvEscape(Object? value) {
  if (value == null) return '';
  var text = value.toString();
  if (value is String && text.isNotEmpty && '=+-@'.contains(text[0])) {
    text = "'$text";
  }
  final needsQuotes =
      text.contains(',') || text.contains('"') || text.contains('\n') || text.contains('\r');
  if (needsQuotes) {
    text = '"${text.replaceAll('"', '""')}"';
  }
  return text;
}

/// Converts vouchers to CSV text (header + one row per voucher).
/// The barcode is written as plain text exactly as stored.
String vouchersToCsv(List<Voucher> vouchers) {
  final buffer = StringBuffer()..writeln(kVoucherCsvHeader.join(','));
  for (final v in vouchers) {
    final row = [
      v.id,
      v.barcode,
      v.depositValue.toStringAsFixed(2),
      v.storeName,
      v.storeLocation,
      v.dateCreated.toIso8601String(),
      v.receiptDateTime?.toIso8601String(),
      v.isUsed ? 1 : 0,
      v.usedDate?.toIso8601String(),
      v.latitude,
      v.longitude,
    ];
    buffer.writeln(row.map(csvEscape).join(','));
  }
  return buffer.toString();
}

/// Writes the CSV to a temporary file and opens the system share sheet
/// (user can pick Google Drive, email, etc.). A UTF-8 byte-order mark is
/// added so Excel reads characters such as the euro sign correctly.
Future<void> exportVouchersCsv(List<Voucher> vouchers) async {
  final dir = await getTemporaryDirectory();
  final stamp = DateTime.now().millisecondsSinceEpoch;
  final file = File('${dir.path}/re_turn_vouchers_$stamp.csv');
  await file.writeAsString('\uFEFF${vouchersToCsv(vouchers)}');

  await SharePlus.instance.share(
    ShareParams(
      text: 'Re-Turn vouchers export',
      files: [XFile(file.path, mimeType: 'text/csv', name: 're_turn_vouchers.csv')],
    ),
  );
}
