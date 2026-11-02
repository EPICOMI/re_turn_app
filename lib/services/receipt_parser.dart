// Pure-Dart receipt text parsing (no Flutter imports) so it can be unit tested.
//
// Returned keys (all optional): 'dateTime' (ISO-8601), 'store', 'location',
// 'deposit' (e.g. "1.25", no currency symbol).

/// Lower-case match word -> display name.
const Map<String, String> kKnownStores = {
  'lidl': 'Lidl',
  'tesco': 'Tesco',
  'supervalu': 'SuperValu',
  'aldi': 'Aldi',
  'dunnes': 'Dunnes',
  'centra': 'Centra',
  'spar': 'Spar',
};

final RegExp _amountPattern = RegExp(r'€?\s*(\d+\.\d{2})');
final RegExp _ymdDateTime =
    RegExp(r'\b(\d{4})-(\d{2})-(\d{2})\s+(\d{2}):(\d{2})\b');
final RegExp _dmyDateTime =
    RegExp(r'\b(\d{2})[/-](\d{2})[/-](\d{4})\s+(\d{2}):(\d{2})\b');

/// Builds an ISO-8601 string, or null if the date/time is impossible
/// (e.g. 31/02/2025 or month 13).
String? _toIso(int year, int month, int day, int hour, int minute) {
  final dt = DateTime(year, month, day, hour, minute);
  if (dt.year != year ||
      dt.month != month ||
      dt.day != day ||
      dt.hour != hour ||
      dt.minute != minute) {
    return null;
  }
  return dt.toIso8601String();
}

/// Finds a date/time in [line]. Day-first (Irish) order is assumed for
/// DD/MM/YYYY and DD-MM-YYYY.
String? findDateTime(String line) {
  final ymd = _ymdDateTime.firstMatch(line);
  if (ymd != null) {
    return _toIso(int.parse(ymd.group(1)!), int.parse(ymd.group(2)!),
        int.parse(ymd.group(3)!), int.parse(ymd.group(4)!), int.parse(ymd.group(5)!));
  }
  final dmy = _dmyDateTime.firstMatch(line);
  if (dmy != null) {
    return _toIso(int.parse(dmy.group(3)!), int.parse(dmy.group(2)!),
        int.parse(dmy.group(1)!), int.parse(dmy.group(4)!), int.parse(dmy.group(5)!));
  }
  return null;
}

/// Returns the display name of the first known store found as a whole word.
String? matchKnownStore(String lowerLine) {
  for (final entry in kKnownStores.entries) {
    if (RegExp(r'\b' + entry.key + r'\b').hasMatch(lowerLine)) {
      return entry.value;
    }
  }
  return null;
}

String? _valueAfterColon(String line) {
  final index = line.indexOf(':');
  if (index < 0) return null;
  final value = line.substring(index + 1).trim();
  return value.isEmpty ? null : value;
}

/// Parses OCR text from a Re-turn receipt.
///
/// Deposit rules: a line mentioning "deposit" or "re-turn" wins over a
/// "total" line, regardless of order. "Total" is only a fallback.
Map<String, String> parseReceiptText(String text) {
  final data = <String, String>{};
  String? depositFromKeyword;
  String? depositFromTotal;
  String? storeFromLabel;

  for (final rawLine in text.split(RegExp(r'\r?\n'))) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final lower = line.toLowerCase();

    if (!data.containsKey('dateTime')) {
      final iso = findDateTime(line);
      if (iso != null) data['dateTime'] = iso;
    }

    if (!data.containsKey('store')) {
      final known = matchKnownStore(lower);
      if (known != null) {
        data['store'] = known;
      } else if (storeFromLabel == null && lower.contains('store')) {
        storeFromLabel = _valueAfterColon(line);
      }
    }

    if (!data.containsKey('location') &&
        (lower.contains('address') || lower.contains('location'))) {
      data['location'] = _valueAfterColon(line) ?? line;
    }

    final amount = _amountPattern.firstMatch(line)?.group(1);
    if (amount != null) {
      if (depositFromKeyword == null &&
          (lower.contains('deposit') || lower.contains('re-turn'))) {
        depositFromKeyword = amount;
      } else if (depositFromTotal == null && lower.contains('total')) {
        depositFromTotal = amount;
      }
    }
  }

  if (!data.containsKey('store') && storeFromLabel != null) {
    data['store'] = storeFromLabel;
  }
  final deposit = depositFromKeyword ?? depositFromTotal;
  if (deposit != null) data['deposit'] = deposit;
  return data;
}
