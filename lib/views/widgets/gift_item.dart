import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/models/model/gift.dart';
import 'package:hedieaty/views/Screens/gift_details_screen.dart';

class GiftItem extends StatelessWidget {
  const GiftItem({
    super.key,
    this.eventLocalId,
    this.eventFireStoreId,
    required this.gift,
    required this.isCurrentUser,
    required this.onChangeStatus,
    required this.onUpdateGift,
    required this.onRemoveButtonPress,
  });
  final Gift gift;
  final int? eventLocalId;
  final String? eventFireStoreId;
  final bool isCurrentUser;
  final void Function() onUpdateGift;
  final void Function(Gift gift) onRemoveButtonPress;
  final void Function(Gift gift) onChangeStatus;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        onTap: () async {
          Event? receivedEvent;
          if (eventFireStoreId == null) {
            receivedEvent = await EventController.retrieveEventById(
                eventId: eventLocalId.toString());
          } else {
            receivedEvent = await EventController.retrieveEventById(
                eventId: eventFireStoreId);
          }
          if (receivedEvent == null) return;
          final DateTime now = DateTime.now();
          final nowDate = DateTime(now.year, now.month, now.day);
          final isEventDateValid = !receivedEvent.date.isBefore(nowDate);
          final updatedGift =
              await GiftController.getUpdatedGiftLocally(gift.localId!);
          if (!context.mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (ctx) => GiftDetailsScreen(
                gift: updatedGift,
                eventLocalId: eventLocalId,
                onUpdateClick: onUpdateGift,
                isCurrentUser: isCurrentUser,
                isEventValid: isEventDateValid,
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.card_giftcard_rounded,
                              size: 40,
                              color: Theme.of(context).primaryColor,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              gift.name,
                              style: Theme.of(context).textTheme.titleLarge,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const Spacer(),
                        if (isCurrentUser)
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              onRemoveButtonPress(gift);
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 20,
                                    color: Colors.grey,
                                  ),
                                  Text(
                                    '\$',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${gift.price}',
                                style: const TextStyle(
                                    color: Color.fromRGBO(97, 97, 97, 1)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.category,
                                  size: 19, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(gift.category,
                                    style: const TextStyle(
                                        color: Color.fromRGBO(97, 97, 97, 1)),
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.info_outline,
                                  size: 19, color: Colors.grey),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  gift.description,
                                  style: const TextStyle(
                                      color: Color.fromRGBO(97, 97, 97, 1)),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 4,
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              if (!isCurrentUser) // Not gift owner
                Column(
                  children: [
                    IconButton(
                      icon: Icon(statusIcon[gift.status]!.icon,
                          color: statusIcon[gift.status]!.color, size: 35),
                      onPressed: () {
                        onChangeStatus(gift);
                      },
                    ),
                    Text(
                      gift.status.name.toUpperCase(),
                      style: TextStyle(color: statusIcon[gift.status]!.color),
                    )
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
