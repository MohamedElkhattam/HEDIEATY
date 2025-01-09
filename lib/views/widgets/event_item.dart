import 'package:flutter/material.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/views/Screens/create_or_update_event.dart';
import 'package:hedieaty/views/Screens/gift_list_screen.dart';

class EventItem extends StatelessWidget {
  final Event event;
  final bool isCurrentUser;
  final String userId;
  final void Function(Event event)? onRemoveButtonPress;
  final void Function()? onUpdateButtonPress;

  const EventItem({
    super.key,
    required this.event,
    required this.userId,
    required this.isCurrentUser,
    this.onUpdateButtonPress,
    this.onRemoveButtonPress,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('find_event'),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: InkWell(
        key: const Key('click_on_event'),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (ctx) => GiftListScreen(
                      isCurrentUser: isCurrentUser,
                      eventLocalId: event.localId,
                      eventId: event.id,
                      userId: userId,
                    )),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.event,
                        size: (onRemoveButtonPress != null) ? 40 : 25,
                        color: Theme.of(context).primaryColor,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        event.name,
                        style: (onRemoveButtonPress != null)
                            ? Theme.of(context).textTheme.titleLarge
                            : Theme.of(context).textTheme.labelLarge,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (isCurrentUser && onRemoveButtonPress != null)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => CreateOrUpdateEvent(
                                  onUpdateEvent: onUpdateButtonPress,
                                  event: event,
                                ),
                              ),
                            );
                            onUpdateButtonPress;
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            onRemoveButtonPress!(event);
                          },
                        ),
                      ],
                    ),
                  if (onRemoveButtonPress == null) const Spacer(),
                  if (onRemoveButtonPress == null)
                    Icon(Icons.arrow_circle_right_outlined,
                        color: Theme.of(context).primaryColor)
                ],
              ),
              if (onRemoveButtonPress != null) const SizedBox(height: 5),
              if (onRemoveButtonPress != null)
                Padding(
                  padding: const EdgeInsets.only(left: 5),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.access_time,
                              size: 19, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${event.date.year}-${event.date.month}-${event.date.day}',
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
                            child: Text(
                              event.category.name,
                              style: const TextStyle(
                                  color: Color.fromRGBO(97, 97, 97, 1)),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 19, color: Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              event.location,
                              style: const TextStyle(
                                  color: Color.fromRGBO(97, 97, 97, 1)),
                              overflow: TextOverflow.ellipsis,
                            ),
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
                              event.description,
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
      ),
    );
  }
}
