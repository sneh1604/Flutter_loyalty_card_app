import 'package:flutter/foundation.dart';
import '../models/card_model.dart';
import '../services/local_storage_service.dart';
import '../services/firebase_service.dart';

class CardsProvider with ChangeNotifier {
  final LocalStorageService _localStorage;
  final FirebaseService _firebaseService;
  List<LoyaltyCard> _cards = [];

  CardsProvider(this._localStorage, this._firebaseService) {
    _loadCards();
    _listenToFirestore();
  }

  List<LoyaltyCard> get cards => _cards;

  Future<void> _loadCards() async {
    _cards = _localStorage.getAllCards();
    notifyListeners();
  }

  void _listenToFirestore() {
    _firebaseService.cardsStream().listen((firestoreCards) {
      // Merge local and remote cards
      for (var firestoreCard in firestoreCards) {
        final localCardIndex =
            _cards.indexWhere((c) => c.id == firestoreCard.id);
        if (localCardIndex >= 0) {
          if (_cards[localCardIndex]
              .lastModified
              .isBefore(firestoreCard.lastModified)) {
            _cards[localCardIndex] = firestoreCard;
          }
        } else {
          _cards.add(firestoreCard);
        }
      }
      notifyListeners();
    });
  }

  Future<void> addCard(LoyaltyCard card) async {
    await _localStorage.saveCard(card);
    _cards.add(card);
    notifyListeners();
    await _syncWithFirebase();
  }

  Future<void> deleteCard(String id) async {
    await _localStorage.deleteCard(id);
    _cards.removeWhere((card) => card.id == id);
    notifyListeners();
    await _syncWithFirebase();
  }

  Future<void> _syncWithFirebase() async {
    final unsyncedCards = _localStorage.getUnsyncedCards();
    if (unsyncedCards.isNotEmpty) {
      await _firebaseService.syncCards(unsyncedCards);
      for (var card in unsyncedCards) {
        card.isSynced = true;
        await _localStorage.saveCard(card);
      }
    }
  }
}
