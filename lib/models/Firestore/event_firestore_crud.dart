import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hedieaty/models/model/event.dart';

class EventFirestoreCrud {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static Future<String?> createEvent(Event event) async {
    try {
      DocumentReference docRef =
          await _db.collection('Events').add(event.toMap());
      return docRef.id;
    } catch (error) {
      return null;
    }
  }

  static Future<List<Event>?> retrieveEvents(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Events')
          .where('eventOwnerId', isEqualTo: userId)
          .get();
      return querySnapshot.docs
          .map((doc) =>
              Event.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (error) {
      return null;
    }
  }

  static Future<Event?> retrieveEventById(String eventId) async {
    try {
      DocumentSnapshot doc = await _db.collection('Events').doc(eventId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return Event.fromMap(data, eventId);
      }
      return null;
    } catch (error) {
      return null;
    }
  }

  static Future<void> updateEvent(Event event) async {
    try {
      await _db.collection('Events').doc(event.id).update(event.toMap());
    } catch (error) {
      rethrow;
    }
  }

  static Future<void> deleteEvent(String eventId) async {
    await _db.collection('Events').doc(eventId).delete();
  }

  static Future<int> countUserEvents(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('Events')
          .where('eventOwnerId', isEqualTo: userId)
          .get();
      return querySnapshot.size;
    } catch (error) {
      return -1;
    }
  }
}
