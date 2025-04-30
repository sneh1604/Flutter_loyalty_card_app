import 'package:hive_flutter/hive_flutter.dart';
import '../models/card_model.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class LocalStorageService {
  static const String _cardsBoxName = 'loyalty_cards';
  late Box<LoyaltyCard> _cardsBox;
  final _encryptionKey = encrypt.Key.fromLength(32);
  late final _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));

  Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(LoyaltyCardAdapter());
    _cardsBox = await Hive.openBox<LoyaltyCard>(_cardsBoxName);
  }

  String _encrypt(String data) {
    final iv = encrypt.IV.fromLength(16);
    return _encrypter.encrypt(data, iv: iv).base64;
  }

  String _decrypt(String encryptedData) {
    final iv = encrypt.IV.fromLength(16);
    return _encrypter.decrypt64(encryptedData, iv: iv);
  }

  Future<void> saveCard(LoyaltyCard card) async {
    card.barcodeData = _encrypt(card.barcodeData);
    await _cardsBox.put(card.id, card);
  }

  List<LoyaltyCard> getAllCards() {
    return _cardsBox.values.map((card) {
      card.barcodeData = _decrypt(card.barcodeData);
      return card;
    }).toList();
  }

  Future<void> deleteCard(String id) async {
    await _cardsBox.delete(id);
  }

  List<LoyaltyCard> getUnsyncedCards() {
    return _cardsBox.values.where((card) => !card.isSynced).toList();
  }
}
