import 'package:flutter_test/flutter_test.dart';
import 'package:re_turn_app/services/receipt_parser.dart';

void main() {
  group('dates', () {
    test('DD/MM/YYYY becomes ISO and parses as a DateTime', () {
      final data = parseReceiptText('LIDL\n25/10/2025 14:30\nRe-turn deposit €1.25');
      expect(data['dateTime'], '2025-10-25T14:30:00.000');
      expect(DateTime.tryParse(data['dateTime']!), isNotNull);
    });

    test('DD-MM-YYYY is day-first', () {
      expect(parseReceiptText('05-11-2025 09:05')['dateTime'], '2025-11-05T09:05:00.000');
    });

    test('YYYY-MM-DD is accepted', () {
      expect(parseReceiptText('2025-08-01 18:45')['dateTime'], '2025-08-01T18:45:00.000');
    });

    test('impossible dates are rejected', () {
      expect(parseReceiptText('31/02/2025 10:00').containsKey('dateTime'), isFalse);
      expect(parseReceiptText('25/13/2025 10:00').containsKey('dateTime'), isFalse);
      expect(parseReceiptText('25/10/2025 25:00').containsKey('dateTime'), isFalse);
    });
  });

  group('store', () {
    test('known stores use display names', () {
      expect(parseReceiptText('SUPERVALU Rathmines')['store'], 'SuperValu');
      expect(parseReceiptText('SPAR Dundrum')['store'], 'Spar');
    });

    test('whole words only', () {
      expect(parseReceiptText('Sparkling water').containsKey('store'), isFalse);
      expect(parseReceiptText('Central Park').containsKey('store'), isFalse);
    });

    test('labelled store is used when no known store is found', () {
      expect(parseReceiptText('Store: Mace Rathmines')['store'], 'Mace Rathmines');
    });

    test('first known store wins', () {
      expect(parseReceiptText('Tesco\nThanks for shopping at Lidl')['store'], 'Tesco');
    });
  });

  group('deposit', () {
    test('deposit line beats total line in either order', () {
      expect(parseReceiptText('Total €12.50\nRe-turn deposit €1.25')['deposit'], '1.25');
      expect(parseReceiptText('Re-turn deposit €1.25\nTotal €12.50')['deposit'], '1.25');
    });

    test('total is a fallback', () {
      expect(parseReceiptText('Total €0.75')['deposit'], '0.75');
    });

    test('no amount means no deposit', () {
      expect(parseReceiptText('Re-turn deposit').containsKey('deposit'), isFalse);
    });
  });

  group('location and input handling', () {
    test('address value is read after the colon', () {
      expect(parseReceiptText('Address: 12 Main St, Dublin')['location'], '12 Main St, Dublin');
    });

    test('empty input gives empty map', () {
      expect(parseReceiptText(''), isEmpty);
    });

    test('Windows line endings are handled', () {
      final data = parseReceiptText('Tesco\r\n25/10/2025 14:30\r\nDeposit €0.15');
      expect(data['store'], 'Tesco');
      expect(data['deposit'], '0.15');
    });
  });
}
