# Re-Turn Digital

A Flutter app that digitises Re-turn deposit return vouchers. Scan a receipt, store the voucher barcode and details on your device, show the barcode at the till, and track what you have used.

> Unofficial personal project. Not affiliated with or endorsed by Re-turn or any retailer.

## Features

- **Scan or import a receipt.** Camera or gallery import. Google ML Kit reads the barcode and runs text recognition (OCR) on the receipt.
- **Automatic field extraction.** Deposit value, store, store address and receipt date/time are pre-filled from the OCR text. You can edit everything before saving, or use manual entry.
- **Voucher wallet.** Tabs for All, Active and Used vouchers, with a summary header (total vouchers, available credit, used vouchers).
- **Sort and filter.** Sort by deposit or date, and filter by store.
- **Barcode display.** Redraws the stored value as a Code 128 barcode. Copy the value, save the barcode image, or share it.
- **Mark as used / delete**, both with confirmation dialogs.
- **Location capture.** Optionally records where a voucher was scanned (latitude/longitude and a readable address).
- **CSV export.** Profile > Settings > Export vouchers (CSV) shares a spreadsheet of all vouchers (see below).
- **Profile and lifetime stats.** Name, bio and avatar saved on device, plus an approximate lifetime credit and items-recycled estimate.

## Tech stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart SDK ^3.8.1) |
| State management | provider |
| Storage | SQLite via sqflite (sqflite_common_ffi on desktop), shared_preferences for profile and lifetime credit |
| Scanning | google_mlkit_barcode_scanning, google_mlkit_text_recognition, image_picker |
| Barcode display | barcode_widget, qr_flutter |
| Location | geolocator, geocoding |
| Sharing and files | share_plus, path_provider, gal |

## Project structure

```
lib/
  main.dart                 App entry, navigation, provider setup
  constants.dart            Shared constants (average deposit estimate)
  models/voucher.dart       Voucher data model
  database/                 SQLite helper (vouchers table)
  providers/                VoucherProvider (state, statistics)
  screens/                  Home, Scan, Profile, Barcode screens
  services/
    receipt_parser.dart     Pure-Dart OCR text parsing (unit tested)
    csv_export.dart         CSV generation and sharing (unit tested)
  widgets/voucher_card.dart Voucher card and details sheet
test/
  receipt_parser_test.dart
  csv_export_test.dart
```

## Getting started

Developed and tested with Flutter 3.47.9 (stable) and Dart 3.13.7.

```
git clone <this repository>
cd re_turn_app
flutter pub get
flutter run
```

Camera, photo library and location permissions are requested at runtime. The ML Kit scanner, camera and GPS plugins need a physical Android or iOS device.

## Receipt parsing rules

The parser lives in `lib/services/receipt_parser.dart` and has no Flutter dependency, so it can be tested on its own.

- **Dates:** DD/MM/YYYY, DD-MM-YYYY (day first) and YYYY-MM-DD with a 24-hour time are converted to ISO-8601. Impossible dates are rejected.
- **Store:** known retailers are matched as whole words (Lidl, Tesco, SuperValu, Aldi, Dunnes, Centra, Spar). A `Store:` label is used as a fallback.
- **Deposit:** a line mentioning deposit or re-turn takes priority over a total line. A total line is only a fallback.
- **Address:** the text after the colon on an address or location line.

## CSV export

The export contains one row per voucher with these columns:

`id, barcode, deposit_value, store_name, store_location, date_created, receipt_date_time, is_used, used_date, latitude, longitude`

- The barcode is written as plain text exactly as stored. When importing into Excel or Power BI, set the barcode column type to Text so long numbers keep their leading zeros.
- Dates are ISO-8601. The file is UTF-8 with a byte-order mark so Excel shows the euro sign correctly.
- Text starting with `=`, `+`, `-` or `@` is prefixed with an apostrophe so spreadsheets do not run it as a formula.

## Testing and status

```
flutter analyze
flutter test
```

- **Unit tests:** 20 tests pass. They cover the receipt parser (dates, store matching, deposit priority, address, line endings) and the CSV service (escaping and row layout).
- **Static analysis:** `flutter analyze` reports no errors. 37 lint-level items remain (see Code quality below).
- **Not yet covered by automated tests:** camera and ML Kit scanning, GPS, the share sheet, and the provider and database layers.

## Privacy

All data stays on the device. Vouchers, profile details and lifetime credit are stored locally. Location is only captured when a voucher is scanned, and it is used for the voucher record only.

## Roadmap and issues

**Features**

- **Voucher expiry:** store an expiry date per voucher and send reminders before it lapses.
- **Cloud backup and sync:** back up vouchers and restore them on a new device.
- **Notifications:** reminders for unused vouchers.
- **Location-based store detection:** use the saved coordinates to suggest the nearest store instead of the scan location.
- **Leaderboard:** compare lifetime recycling stats with friends.
- **OCR confidence:** flag low-confidence fields for review before saving.

**Data and logic**

- **Unique barcode constraint:** add a UNIQUE constraint on barcode with a database migration. Duplicate checking currently happens in the provider and only compares against active vouchers.
- **Better lifetime stats:** replace the average-deposit estimate (`kAvgDepositEuro`) with a real item count where available, and decide how deleting a voucher should affect lifetime credit.
- **Camera permission:** only request camera access when using the camera, not for gallery import.

**Code quality**

- Replace `print` calls with a logging framework (`barcode_screen.dart`, `voucher_card.dart`).
- Migrate deprecated APIs: `withOpacity` to `withValues` (`scan_screen.dart`), and the screen brightness methods to their application-level replacements (`barcode_screen.dart`).
- Guard `BuildContext` use after `await` with `mounted` checks (`profile_screen.dart`, `scan_screen.dart`, `voucher_card.dart`).
- Remove dead code: the unused storage-permission helper and always-true null checks in `voucher_card.dart`, and the unused `image_cropper` import in `profile_screen.dart`.
- Add unit tests for the provider and database layers.
