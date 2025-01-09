import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/friend_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/models/model/friend.dart';
import 'package:hedieaty/views/Screens/event_list_screen.dart';
import 'package:hedieaty/views/Screens/gift_list_screen.dart';

class FriendItem extends StatefulWidget {
  const FriendItem({super.key, required this.friend});
  final Friend friend;

  @override
  State<FriendItem> createState() => _FriendItemState();
}

class _FriendItemState extends State<FriendItem> {
  int eventCount = 0;
  Event? event;
  void getEventCount() async {
    try {
      final count = await FriendController.getFriendEventCount(
          widget.friend.friendId!); //
      if (count == 1) {
        final receivedEvents =
            await EventController.getEventList(widget.friend.friendId!, false);
        event = receivedEvents[0];
      }
      setState(() {
        eventCount = count;
      });
    } catch (error) {
      log(error.toString());
    }
  }

  @override
  void initState() {
    super.initState();
    getEventCount();
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (ctx) => eventCount != 1
                      ? EventListScreen(userId: widget.friend.friendId!)
                      : GiftListScreen(
                          eventId: event!.id!,
                          userId: widget.friend.friendId!,
                          isCurrentUser: false,
                        )),
            ),
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/male-avatar.png'),
        ),
        title: Text(widget.friend.name),
        subtitle: Text(eventCount > 0
            ? 'Upcoming Events: $eventCount'
            : 'No Upcoming Events'),
        trailing: eventCount > 0
            ? Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.circle,
                    size: 25,
                    color: Colors.green,
                  ),
                  Text(
                    '$eventCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              )
            : null);
  }
}
