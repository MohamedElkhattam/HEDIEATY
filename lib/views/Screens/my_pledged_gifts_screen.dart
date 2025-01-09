import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/gift_controller.dart';
import 'package:hedieaty/models/model/gift.dart';

class MyPledgedGiftsScreen extends StatefulWidget {
  const MyPledgedGiftsScreen({super.key});

  @override
  State<MyPledgedGiftsScreen> createState() => _MyPledgedGiftsScreenState();
}

class _MyPledgedGiftsScreenState extends State<MyPledgedGiftsScreen> {
  Future<List<Map<String, dynamic>>?>? pledgedGiftsFuture;

  @override
  void initState() {
    super.initState();
    pledgedGiftsFuture = GiftController.retrieveUserPledgedGifts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('my_pledged_gifts'),
      appBar: AppBar(
        title: const Text(
          'My Pledged Gifts',
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: pledgedGiftsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(
              child: Text("You haven't pledged any gifts yet."),
            );
          }
          final gifts = snapshot.data!;
          return ListView.builder(
            itemCount: gifts.length,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            itemBuilder: (context, index) {
              final giftData = gifts[index];
              final Gift gift = giftData['gift'];
              final String eventName = giftData['eventName'];
              final String dueDate = giftData['eventDueDate'];

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    radius: 30,
                    child: Icon(
                      Icons.card_giftcard,
                      size: 30,
                      color: Colors.white,
                    ),
                  ),
                  title: Text(
                    gift.name[0].toUpperCase() + gift.name.substring(1),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            'For: ${gift.giftOwnerName}',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.event, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            'Event: $eventName',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 18),
                          const SizedBox(width: 5),
                          Text(
                            'Due Date: $dueDate',
                            style: const TextStyle(
                                color: Colors.black, fontSize: 16),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
