import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/models/model/gift.dart';

class GiftFirestoreCrud {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<String> createGift(Gift gift) async {
    DocumentReference docref = await _db.collection('Gifts').add(gift.toMap());
    return docref.id;
  }

  static Future<List<Gift>?> retrieveGiftsForSingleEvent(String eventId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Gifts')
          .where('eventId', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs
            .map((doc) =>
                Gift.fromMap(doc.data() as Map<String, dynamic>, doc.id))
            .toList();
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<Gift?> retrieveGiftById(String giftId) async {
    try {
      DocumentSnapshot docSnapshot =
          await _db.collection('Gifts').doc(giftId).get();

      if (docSnapshot.exists) {
        return Gift.fromMap(
            docSnapshot.data() as Map<String, dynamic>, docSnapshot.id);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<void> updateGift(Gift gift) async {
    try {
      if (gift.id == null) {
        throw Exception("Gift ID cannot be null");
      }
      await _db.collection('Gifts').doc(gift.id).update(gift.toMap());
    } catch (error) {
      throw error.toString();
    }
  }

  static Future<void> deleteGift(String giftId) async {
    await _db.collection('Gifts').doc(giftId).delete();
  }

  static Future<void> giftPledge(String giftId, String statusName) async {
    await _db.collection('Gifts').doc(giftId).update({
      'status': statusName,
      'pledgedBy': _auth.currentUser!.uid,
    });
  }

  static Future<List<Gift>?> getUserPlededByGifts(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Gifts')
          .where('pledgedBy', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map(
              (doc) => Gift.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (error) {
      return null;
    }
  }
}
