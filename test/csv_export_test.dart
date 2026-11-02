import 'package:flutter_test/flutter_test.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/services/csv_export.dart';

void main() {
  group('csvEscape', () {
    test('null becomes empty', () => expect(csvEscape(null), ''));

    test('commas force quoting', () => expect(csvEscape('a,b'), '"a,b"'));

    test('quotes are doubled', () {
      expect(csvEscape('He said "hi"'), '"He said ""hi"""');
    });

    test('formula-like strings are neutralised', () {
      expect(csvEscape('=SUM(A1)'), "'=SUM(A1)");
    });

    test('negative numbers are left alone', () => expect(csvEscape(-1.5), '-1.5'));
  });

  group('vouchersToCsv', () {
    test('header plus one row per voucher', () {
      final csv = vouchersToCsv([
        Voucher(
          id: 1,
          barcode: '123',
          depositValue: 0.25,
          storeName: 'Lidl',
          dateCreated: DateTime(2025, 8, 1, 10, 0),
        ),
      ]);
      final lines = csv.trim().split('\n');
      expect(lines.length, 2);
      expect(lines[0], kVoucherCsvHeader.join(','));
      expect(lines[1], '1,123,0.25,Lidl,,2025-08-01T10:00:00.000,,0,,,');
    });
  });
}
