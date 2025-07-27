import 'dart:async';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:re_turn_app/models/voucher.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('vouchers.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const textType = 'TEXT NOT NULL';
    const integerType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    await db.execute('''
      CREATE TABLE vouchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        barcode $textType,
        deposit_value $realType,
        store_name $textType,
        store_location TEXT,
        date_created $textType,
        receipt_date_time TEXT,
        is_used INTEGER DEFAULT 0,
        used_date TEXT,
        latitude REAL,
        longitude REAL
      )
    ''');
  }

  Future<int> createVoucher(Voucher voucher) async {
    final db = await instance.database;
    return await db.insert('vouchers', voucher.toJson());
  }

  Future<List<Voucher>> getAllVouchers() async {
    final db = await instance.database;
    const orderBy = 'date_created DESC';
    final result = await db.query('vouchers', orderBy: orderBy);
    return result.map((json) => Voucher.fromJson(json)).toList();
  }

  Future<List<Voucher>> getUnusedVouchers() async {
    final db = await instance.database;
    final result = await db.query(
      'vouchers',
      where: 'is_used = ?',
      whereArgs: [0],
      orderBy: 'date_created DESC',
    );
    return result.map((json) => Voucher.fromJson(json)).toList();
  }

  Future<double> getTotalDepositValue() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT SUM(deposit_value) as total FROM vouchers WHERE is_used = 0',
    );
    return result.first['total'] as double? ?? 0.0;
  }

  Future<int> markVoucherAsUsed(int id) async {
    final db = await instance.database;
    return await db.update(
      'vouchers',
      {'is_used': 1, 'used_date': DateTime.now().toIso8601String()},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> deleteVoucher(int id) async {
    final db = await instance.database;
    return await db.delete('vouchers', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}