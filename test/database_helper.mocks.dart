import 'package:mockito/mockito.dart';
import 'package:re_turn_app/database/database_helper.dart';
import 'package:re_turn_app/models/voucher.dart';

class MockDatabaseHelper extends Mock implements DatabaseHelper {
  @override
  Future<int> createVoucher(Voucher voucher) {
    return super.noSuchMethod(
      Invocation.method(#createVoucher, [voucher]),
      returnValue: Future.value(1),
    );
  }

  @override
  Future<int> deleteVoucher(int id) {
    return super.noSuchMethod(
      Invocation.method(#deleteVoucher, [id]),
      returnValue: Future.value(1),
    );
  }

  @override
  Future<List<Voucher>> getAllVouchers() {
    return super.noSuchMethod(
      Invocation.method(#getAllVouchers, []),
      returnValue: Future.value(<Voucher>[]),
    );
  }

  @override
  Future<double> getTotalDepositValue() {
    return super.noSuchMethod(
      Invocation.method(#getTotalDepositValue, []),
      returnValue: Future.value(0.0),
    );
  }

  @override
  Future<int> markVoucherAsUsed(int id) {
    return super.noSuchMethod(
      Invocation.method(#markVoucherAsUsed, [id]),
      returnValue: Future.value(1),
    );
  }
}
