import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/Firestore/event_firestore_crud.dart';
import 'package:hedieaty/service/notification_service.dart';

class LocalPushNotification extends StatefulWidget {
  final Widget child;
  const LocalPushNotification({super.key, required this.child});
  @override
  State<LocalPushNotification> createState() => _LocalPushNotificationState();
}

class _LocalPushNotificationState extends State<LocalPushNotification> {
  final NotificationService _notificationService = NotificationService();
  Stream<QuerySnapshot<Map<String, dynamic>>>? _giftStream;
  final Set<String> _notifiedGifts = {};

  @override
  void initState() {
    super.initState();
    _notificationService.initNotification();
    _startGiftListener();
  }

  void _startGiftListener() {
    _giftStream = FirebaseFirestore.instance.collection('Gifts').snapshots();

    _giftStream!.listen((snapshot) async {
      for (var docChange in snapshot.docChanges) {
        if (docChange.type == DocumentChangeType.modified) {
          final data = docChange.doc.data();
          if (data != null) {
            final docId = docChange.doc.id;
            final newStatus = data['status'];
            final giftName = data['name'];
            final eventId = data['eventId'];

            final notificationKey = '$docId-$newStatus';

            if (newStatus == 'pledged' &&
                !_notifiedGifts.contains(notificationKey)) {
              final event =
                  await EventFirestoreCrud.retrieveEventById(eventId!);
              final isCurrentUserOwner =
                  await UserController.isCurrentUser(event!.eventOwnerId!);

              if (isCurrentUserOwner) {
                _notificationService.showNotification(
                  id: notificationKey.hashCode,
                  title: 'Gift $giftName is updated',
                  body: 'The Gift "$giftName" is now $newStatus.',
                );
                _notifiedGifts.add(notificationKey);
              }
            }
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
