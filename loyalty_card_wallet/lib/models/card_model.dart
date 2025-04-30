import 'package:uuid/uuid.dart';

class LoyaltyCard {
  final String id;
  String title;
  String barcodeData;
  DateTime? expirationDate;
  String notes;
  bool isSynced;
  DateTime lastModified;

  LoyaltyCard({
    String? id,
    required this.title,
    required this.barcodeData,
    this.expirationDate,
    this.notes = '',
    this.isSynced = false,
  })  : id = id ?? const Uuid().v4(),
        lastModified = DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'barcodeData': barcodeData,
        'expirationDate': expirationDate?.toIso8601String(),
        'notes': notes,
        'lastModified': lastModified.toIso8601String(),
        'isSynced': isSynced,
      };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        id: json['id'],
        title: json['title'],
        barcodeData: json['barcodeData'],
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'])
            : null,
        notes: json['notes'] ?? '',
        isSynced: json['isSynced'] ?? false,
      );

  // Add method to handle manual barcode input
  void updateBarcodeData(String data) {
    barcodeData = data;
    lastModified = DateTime.now();
  }
}
