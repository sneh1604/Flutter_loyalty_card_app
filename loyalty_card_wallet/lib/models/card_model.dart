import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'card_model.g.dart';

@HiveType(typeId: 0)
class LoyaltyCard extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String barcodeData;

  @HiveField(3)
  DateTime? expirationDate;

  @HiveField(4)
  String notes;

  @HiveField(5)
  bool isSynced;

  @HiveField(6)
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
      };

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) => LoyaltyCard(
        id: json['id'],
        title: json['title'],
        barcodeData: json['barcodeData'],
        expirationDate: json['expirationDate'] != null
            ? DateTime.parse(json['expirationDate'])
            : null,
        notes: json['notes'] ?? '',
      );
}
