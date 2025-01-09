import 'package:firebase_auth/firebase_auth.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/DB/user_local_crud.dart';
import 'package:hedieaty/models/Firestore/event_firestore_crud.dart';
import 'package:hedieaty/models/DB/event_local_crud.dart';
import 'package:hedieaty/models/model/event.dart';

class EventController {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<Event?> saveNewEvent(String name, String description,
      String location, DateTime date, Category category) async {
    // using these fields without check as check made before function call
    try {
      Event myEvent = Event(
        name: name,
        date: date,
        location: location,
        description: description,
        eventOwnerId: _auth.currentUser!.uid,
        category: category,
      );

      myEvent.eventOwnerLocalId =
          await UserLocalCRUD.getUserLocalIdbyFireStoreId(
              _auth.currentUser!.uid);
      myEvent.localId = await EventLocalCrud.createEvent(myEvent);
      return myEvent;
    } catch (error) {
      return null;
    }
  }

  static Future<void> updateExistingEvent(
    String name,
    String description,
    String location,
    DateTime date,
    Category category,
    int localId,
  ) async {
    try {
      final Event? myEvent =
          await EventLocalCrud.retrieveEventByLocalId(localId);
      if (myEvent == null) throw ('No Event Found');
      myEvent.name = name;
      myEvent.date = date;
      myEvent.category = category;
      myEvent.location = location;
      myEvent.description = description;
      myEvent.eventOwnerId = _auth.currentUser!.uid;
      myEvent.eventOwnerLocalId =
          await UserLocalCRUD.getUserLocalIdbyFireStoreId(
              _auth.currentUser!.uid);
      myEvent.localId = localId;
      await EventLocalCrud.updateEvent(myEvent);
      if (myEvent.id == null) return;
      await EventFirestoreCrud.updateEvent(myEvent);
    } catch (error) {
      return;
    }
  }

  static Future<void> deleteEvent(int localId, {id}) async {
    id != null ? await EventFirestoreCrud.deleteEvent(id) : null;
    await EventLocalCrud.deleteEvent(localId);
  }

  static Future<List<Event>> getEventList(
      String fireStoreId, bool isCurrentUser) async {
    try {
      final List<Event>? eventList;
      if (isCurrentUser) {
        final userLocalId = await UserController.retrievCurrentUserLocalId();
        eventList = await EventLocalCrud.retrieveEvents(userLocalId);
        if (eventList!.isEmpty) {
          return [];
        }
      } else {
        eventList = await EventFirestoreCrud.retrieveEvents(fireStoreId);
        if (eventList!.isEmpty) {
          return [];
        }
      }
      return eventList;
    } catch (error) {
      return [];
    }
  }

  static Future<Event?> retrieveEventById({eventId}) async {
    int localId = int.tryParse(eventId) ?? -1;
    Event? event;
    if (localId == -1) {
      // Search in FireStore
      event = await EventFirestoreCrud.retrieveEventById(eventId);
    } else {
      // Search Locally
      event = await EventLocalCrud.retrieveEventByLocalId(localId);
    }
    return event;
  }

  static Future<void> syncEvents(String userId, int userLocalId) async {
    try {
      final firestoreEvents = await EventFirestoreCrud.retrieveEvents(userId);
      var localEvents = await EventLocalCrud.retrieveEventsByFirestore(userId);
      if (firestoreEvents == null || firestoreEvents.isEmpty) {
        return;
      }
      localEvents ??= [];
      for (final event in firestoreEvents) {
        if (!localEvents.contains(event)) {
          event.eventOwnerLocalId = userLocalId;
          final eventLocalDBId = await EventLocalCrud.createEvent(event);
          await GiftController.syncGifts(event.id!, eventLocalDBId!);
        }
      }
    } catch (error) {
      return;
    }
  }
}
