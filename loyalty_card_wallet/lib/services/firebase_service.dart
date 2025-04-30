import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  FirebaseService({required this.userId});

  Future<void> syncCards(List<LoyaltyCard> cards) async {
    final batch = _firestore.batch();

    for (var card in cards) {
      final docRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('cards')
          .doc(card.id);

      batch.set(docRef, card.toJson(), SetOptions(merge: true));
    }

    await batch.commit();
  }

  Stream<List<LoyaltyCard>> cardsStream() {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cards')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => LoyaltyCard.fromJson(doc.data()))
            .toList());
  }
}
