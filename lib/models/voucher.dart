class Voucher {
  final int? id;
  final String barcode;
  final double depositValue;
  final String storeName;
  final String? storeLocation;
  final DateTime dateCreated;
  final DateTime? receiptDateTime; // Specifically for when the date/time can be pulled while scanning a receipt
  final bool isUsed;
  final DateTime? usedDate;
  final double? latitude;
  final double? longitude;

  Voucher({
    this.id,
    required this.barcode,
    required this.depositValue,
    required this.storeName,
    this.storeLocation,
    required this.dateCreated,
    this.receiptDateTime,
    this.isUsed = false,
    this.usedDate,
    this.latitude,
    this.longitude,
  });

  // Convert Voucher to Map for database storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'deposit_value': depositValue,
      'store_name': storeName,
      'store_location': storeLocation,
      'date_created': dateCreated.toIso8601String(),
      'receipt_date_time': receiptDateTime?.toIso8601String(),
      'is_used': isUsed ? 1 : 0,
      'used_date': usedDate?.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  // Create Voucher from Map (database retrieval)
  factory Voucher.fromJson(Map<String, dynamic> json) {
    return Voucher(
      id: json['id'] as int?,
      barcode: json['barcode'] as String,
      depositValue: json['deposit_value'] as double,
      storeName: json['store_name'] as String,
      storeLocation: json['store_location'] as String?,
      dateCreated: DateTime.parse(json['date_created'] as String),
      receiptDateTime: json['receipt_date_time'] != null
          ? DateTime.parse(json['receipt_date_time'] as String)
          : null,
      isUsed: (json['is_used'] as int) == 1,
      usedDate: json['used_date'] != null
          ? DateTime.parse(json['used_date'] as String)
          : null,
      latitude: json['latitude'] as double?,
      longitude: json['longitude'] as double?,
    );
  }

  // Copy with method for updates
  Voucher copyWith({
    int? id,
    String? barcode,
    double? depositValue,
    String? storeName,
    String? storeLocation,
    DateTime? dateCreated,
    DateTime? receiptDateTime,
    bool? isUsed,
    DateTime? usedDate,
    double? latitude,
    double? longitude,
  }) {
    return Voucher(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      depositValue: depositValue ?? this.depositValue,
      storeName: storeName ?? this.storeName,
      storeLocation: storeLocation ?? this.storeLocation,
      dateCreated: dateCreated ?? this.dateCreated,
      receiptDateTime: receiptDateTime ?? this.receiptDateTime,
      isUsed: isUsed ?? this.isUsed,
      usedDate: usedDate ?? this.usedDate,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }
}