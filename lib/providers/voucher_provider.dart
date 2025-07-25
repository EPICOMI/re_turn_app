import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:re_turn_app/models/voucher.dart';
import 'package:re_turn_app/database/database_helper.dart';

class VoucherProvider with ChangeNotifier {
  List<Voucher> _vouchers = [];
  double _totalValue = 0.0;
  bool _isLoading = false;
  double _lifetimeCredit = 0.0;

  List<Voucher> get vouchers => _vouchers;
  List<Voucher> get activeVouchers =>
      _vouchers.where((voucher) => !voucher.isUsed).toList();
  List<Voucher> get usedVouchers =>
      _vouchers.where((voucher) => voucher.isUsed).toList();
  double get totalValue => _totalValue;
  bool get isLoading => _isLoading;
  double get lifetimeCredit => _lifetimeCredit;

  VoucherProvider() {
    loadVouchers();
    _loadLifetimeCredit();
  }

  // Load all vouchers from database
  Future<void> loadVouchers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _vouchers = await DatabaseHelper.instance.getAllVouchers();
      _totalValue = await DatabaseHelper.instance.getTotalDepositValue();
    } catch (e) {
      debugPrint('Error loading vouchers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _loadLifetimeCredit() async {
    final prefs = await SharedPreferences.getInstance();
    _lifetimeCredit = prefs.getDouble('lifetimeCredit') ?? 0.0;
    notifyListeners();
  }

  Future<void> _updateLifetimeCredit(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    _lifetimeCredit += amount;
    await prefs.setDouble('lifetimeCredit', _lifetimeCredit);
    notifyListeners();
  }

  // Add new voucher
  Future<bool> addVoucher(Voucher voucher) async {
    try {
      // Check if barcode already exists
      if (_vouchers.any((v) => v.barcode == voucher.barcode && !v.isUsed)) {
        return false; // Duplicate barcode
      }

      final id = await DatabaseHelper.instance.createVoucher(voucher);
      final newVoucher = voucher.copyWith(id: id);

      _vouchers.insert(0, newVoucher);
      _totalValue += voucher.depositValue;
      await _updateLifetimeCredit(voucher.depositValue);

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error adding voucher: $e');
      return false;
    }
  }

  // Mark voucher as used
  Future<bool> markVoucherAsUsed(int voucherId) async {
    try {
      await DatabaseHelper.instance.markVoucherAsUsed(voucherId);

      final index = _vouchers.indexWhere((voucher) => voucher.id == voucherId);
      if (index != -1) {
        final voucher = _vouchers[index];
        _vouchers[index] = voucher.copyWith(
          isUsed: true,
          usedDate: DateTime.now(),
        );
        _totalValue -= voucher.depositValue;
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error marking voucher as used: $e');
      return false;
    }
  }

  // Delete voucher
  Future<bool> deleteVoucher(int voucherId) async {
    try {
      await DatabaseHelper.instance.deleteVoucher(voucherId);

      final index = _vouchers.indexWhere((voucher) => voucher.id == voucherId);
      if (index != -1) {
        final voucher = _vouchers[index];
        if (!voucher.isUsed) {
          _totalValue -= voucher.depositValue;
        }
        _vouchers.removeAt(index);
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error deleting voucher: $e');
      return false;
    }
  }

  // Get vouchers by store
  List<Voucher> getVouchersByStore(String storeName) {
    return _vouchers
        .where((voucher) =>
            voucher.storeName.toLowerCase().contains(storeName.toLowerCase()) == true)
        .toList();
  }

  // Get statistics
  Map<String, dynamic> getStatistics() {
    final total = _vouchers.length;
    final active = activeVouchers.length;
    final used = usedVouchers.length;

    return {
      'total': total,
      'active': active,
      'used': used,
      'totalValue': _totalValue,
      'usedValue': _vouchers
          .where((v) => v.isUsed)
          .fold(0.0, (sum, v) => sum + v.depositValue),
      'lifetimeCredit': lifetimeCredit,
    };
  }
}