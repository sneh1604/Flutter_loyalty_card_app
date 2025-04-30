import 'dart:convert';
import 'package:shared_preferences.dart';
import '../models/card_model.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class LocalStorageService {
  static const String _cardsKey = 'loyalty_cards';
  late SharedPreferences _prefs;
  final _encryptionKey = encrypt.Key.fromLength(32);
  late final _encrypter = encrypt.Encrypter(encrypt.AES(_encryptionKey));

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
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
    final cards = getAllCards();
    final index = cards.indexWhere((c) => c.id == card.id);

    if (index >= 0) {
      cards[index] = card;
    } else {
      cards.add(card);
    }

    final encryptedCards = cards.map((card) {
      var jsonCard = card.toJson();
      jsonCard['barcodeData'] = _encrypt(jsonCard['barcodeData']);
      return jsonCard;
    }).toList();

    await _prefs.setString(_cardsKey, json.encode(encryptedCards));
  }

  List<LoyaltyCard> getAllCards() {
    final String? cardsJson = _prefs.getString(_cardsKey);
    if (cardsJson == null) return [];

    final List<dynamic> decodedList = json.decode(cardsJson);
    return decodedList.map((item) {
      item['barcodeData'] = _decrypt(item['barcodeData']);
      return LoyaltyCard.fromJson(item);
    }).toList();
  }

  Future<void> deleteCard(String id) async {
    final cards = getAllCards();
    cards.removeWhere((card) => card.id == id);

    final encryptedCards = cards.map((card) {
      var jsonCard = card.toJson();
      jsonCard['barcodeData'] = _encrypt(jsonCard['barcodeData']);
      return jsonCard;
    }).toList();

    await _prefs.setString(_cardsKey, json.encode(encryptedCards));
  }

  List<LoyaltyCard> getUnsyncedCards() {
    return getAllCards().where((card) => !card.isSynced).toList();
  }
}
