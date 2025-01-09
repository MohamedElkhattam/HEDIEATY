import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/DB/event_local_crud.dart';
import 'package:hedieaty/models/DB/gift_local_crud.dart';
import 'package:hedieaty/models/Firestore/event_firestore_crud.dart';
import 'package:hedieaty/models/Firestore/gift_firestore_crud.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/models/model/gift.dart';
import 'package:hedieaty/models/model/user_model.dart';
import 'package:hedieaty/service/fcm_service.dart';

class GiftController {
  static Future<List<Gift>> getGiftList(
    String eventId,
    bool isCurrentUser,
  ) async {
    try {
      final List<Gift> gifts;
      if (isCurrentUser) {
        gifts = await GiftLocalCrud.retrieveGiftsByEventLocalId(
                int.parse(eventId)) ??
            [];
      } else {
        gifts =
            await GiftFirestoreCrud.retrieveGiftsForSingleEvent(eventId) ?? [];
      }
      return gifts;
    } catch (error) {
      return [];
    }
  }

  static Future<Gift?> createGift(
    String giftName,
    String giftCategory,
    double giftPrice,
    String giftDesription,
    Status giftStatus,
    int eventLocalId, {
    imagePath,
  }) async {
    try {
      final giftOwner = await getGiftOwnerName();
      Gift gift = Gift(
        name: giftName,
        category: giftCategory,
        price: giftPrice,
        description: giftDesription,
        giftOwnerName: giftOwner,
        status: giftStatus,
        imagePath: imagePath,
      );
      gift.evenLocalId = eventLocalId;
      gift.localId = await GiftLocalCrud.createGift(gift);
      return gift;
    } catch (error) {
      return null;
    }
  }

  static Future<void> updateExistingGift(
    String giftName,
    String giftCategory,
    double giftPrice,
    String giftDesription,
    int eventLocalId,
    int localId,
    Status giftStatus, {
    imagePath,
  }) async {
    final giftOwner = await getGiftOwnerName();
    try {
      final Gift? gift = await GiftLocalCrud.retrieveGiftByLocalId(localId);
      if (gift == null) return;
      gift.name = giftName;
      gift.category = giftCategory;
      gift.price = giftPrice;
      gift.description = giftDesription;
      gift.status = giftStatus;
      gift.imagePath = imagePath;
      gift.giftOwnerName = giftOwner;
      await GiftLocalCrud.updateGift(gift);
      if (gift.id == null) return;
      await GiftFirestoreCrud.updateGift(gift);
    } catch (error) {
      return;
    }
  }

  static Future<void> deleteGift(int giftLocalId, {giftId}) async {
    try {
      giftId != null ? await GiftFirestoreCrud.deleteGift(giftId) : null;
      await GiftLocalCrud.deleteGift(giftLocalId);
    } catch (error) {
      return;
    }
  }

  static Future<bool> isGiftPledger(Gift gift) async {
    final currentUserId = await UserController.retrievCurrentUserId();
    return gift.pledgedBy == currentUserId;
    // if iam not the gift pledger i will not be able to update the gift status
  }

  static Future<String> getGiftOwnerName() async {
    final currentUserId = await UserController.retrievCurrentUserId();
    final userName = await UserController.getUserFullName(currentUserId);
    return userName;
  }

  static Future<List<Map<String, dynamic>>?> retrieveUserPledgedGifts() async {
    try {
      List<Map<String, dynamic>> addedEventToGift = [];
      final currentUser = await UserController.retrievCurrentUserId();
      final gifts = await GiftFirestoreCrud.getUserPlededByGifts(currentUser);
      if (gifts == null) return null;
      for (final gift in gifts) {
        final event = await EventFirestoreCrud.retrieveEventById(gift.eventId!);
        if (event == null) continue;
        addedEventToGift.add({
          'gift': gift,
          'eventName': event.name,
          'eventDueDate':
              '${event.date.year} / ${event.date.month} / ${event.date.day}',
        });
      }
      return addedEventToGift;
    } catch (error) {
      return null;
    }
  }

  static Future<String> managePledgingGifts(Gift gift) async {
    try {
      final user = await getGiftOwner(gift);
      // will be Pledged
      if (gift.status.name == Status.available.name) {
        await GiftFirestoreCrud.giftPledge(gift.id!, Status.pledged.name);
        await GiftLocalCrud.giftPledge(gift.id!, Status.pledged.name);
        gift.status = Status.pledged;
        await FcmService().sendFCMMessage(user, gift);
        return 'Pledged';
      }
      // will be Purchased
      else if (gift.status.name == Status.pledged.name) {
        if (await GiftController.isGiftPledger(gift) == false) {
          throw ('Git Plegded by someone else');
        }

        await GiftFirestoreCrud.giftPledge(gift.id!, Status.purchased.name);
        await GiftLocalCrud.giftPledge(gift.id!, Status.purchased.name);
        gift.status = Status.purchased;
        await FcmService().sendFCMMessage(user, gift);
        return 'Purchased';
      }
      // is already purchased
      return 'Already Purchased';
    } catch (error) {
      rethrow;
    }
  }

  static Future<UserModel> getGiftOwner(Gift gift) async {
    try {
      final event = await EventFirestoreCrud.retrieveEventById(gift.eventId!);
      final user =
          await UserController.retrieveUserModel(userid: event!.eventOwnerId);
      return user;
    } catch (error) {
      throw Exception(error.toString());
    }
  }

  static Future<void> syncGifts(String eventId, int eventLocalDBId) async {
    try {
      final firestoreGifts =
          await GiftFirestoreCrud.retrieveGiftsForSingleEvent(eventId);
      var localGifts =
          await GiftLocalCrud.retrieveGiftsByEventFirestoreId(eventId);
      if (firestoreGifts == null || firestoreGifts.isEmpty) return;

      localGifts ??= [];
      for (final gift in firestoreGifts) {
        if (!localGifts.contains(gift)) {
          gift.evenLocalId = eventLocalDBId;
          GiftLocalCrud.createGift(gift);
        }
      }
    } catch (error) {
      return;
    }
  }

  static Future<void> publishGiftList(int evnetLocalId) async {
    try {
      // 1) Retrieve event from local DB
      final Event? event = await EventController.retrieveEventById(
          eventId: evnetLocalId.toString());
      if (event == null) throw ('Error');

      // 2) If the event is not in Firestore, create it
      if (event.id == null) {
        final documentId = await EventFirestoreCrud.createEvent(event);
        event.id = documentId;
        await EventLocalCrud.updateEvent(event);
      }
      // 3) Retrieve gifts from local DB
      final List<Gift>? gifts =
          await GiftLocalCrud.retrieveGiftsByEventLocalId(event.localId!);
      if (gifts == null || gifts.isEmpty) return;

      // 4) Push only gifts with null Firestore IDs
      for (final gift in gifts) {
        if (gift.id == null) {
          gift.eventId = event.id;
          gift.id = await GiftFirestoreCrud.createGift(gift);
          await GiftLocalCrud.updateGift(gift);
        }
      }
    } catch (e) {
      return;
    }
  }

  static Future<Gift> getUpdatedGiftLocally(int giftId) async {
    final gift = await GiftLocalCrud.retrieveGiftByLocalId(giftId);
    return gift!;
  }

  static Future<Gift> getUpdatedGiftFireStore(String giftId) async {
    final gift = await GiftFirestoreCrud.retrieveGiftById(giftId);
    return gift!;
  }
}
