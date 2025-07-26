import 'package:flutter_test/flutter_test.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/providers/voucher_provider.dart';
import 'package:mockito/mockito.dart';
import 'database_helper.mocks.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  group('VoucherProvider', () {
    late VoucherProvider voucherProvider;
    late MockDatabaseHelper mockDatabaseHelper;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockDatabaseHelper = MockDatabaseHelper();
      voucherProvider = VoucherProvider(databaseHelper: mockDatabaseHelper);
    });

    test('deleteOldVouchers should remove vouchers older than 7 days', () async {
      // Arrange
      final oldVoucher = Voucher(
        id: 1,
        barcode: '123',
        depositValue: 1.0,
        storeName: 'Test Store',
        dateCreated: DateTime.now(),
        isUsed: true,
        usedDate: DateTime.now().subtract(const Duration(days: 8)),
      );
      final newVoucher = Voucher(
        id: 2,
        barcode: '456',
        depositValue: 2.0,
        storeName: 'Test Store',
        dateCreated: DateTime.now(),
        isUsed: true,
        usedDate: DateTime.now().subtract(const Duration(days: 1)),
      );

      when(mockDatabaseHelper.getAllVouchers()).thenAnswer((_) async => [oldVoucher, newVoucher]);
      when(mockDatabaseHelper.getTotalDepositValue()).thenAnswer((_) async => 3.0);
      when(mockDatabaseHelper.deleteVoucher(1)).thenAnswer((_) async => 1);
      when(mockDatabaseHelper.getUnusedVouchers()).thenAnswer((_) async => []);


      await voucherProvider.loadVouchers();

      // Act
      await voucherProvider.deleteOldVouchers();

      // Assert
      expect(voucherProvider.vouchers.length, 1);
      expect(voucherProvider.vouchers.first.id, 2);
      verify(mockDatabaseHelper.deleteVoucher(1)).called(1);
    });
  });
}
