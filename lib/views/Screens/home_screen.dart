import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/friend_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/models/model/friend.dart';
import 'package:hedieaty/models/model/user_model.dart';
import 'package:hedieaty/views/Screens/create_or_update_event.dart';
import 'package:hedieaty/views/Screens/profile_screen.dart';
import 'package:hedieaty/views/widgets/add_friend_dialog.dart';
import 'package:hedieaty/views/widgets/friend_item.dart';

class HomeScreen extends StatefulWidget {
  final UserModel user;
  const HomeScreen({super.key, required this.user});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Friend>? myFriends;
  List<Friend>? filteredFriends;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final retrievedFriends = await FriendController.getMyFriends();
    setState(() {
      myFriends = retrievedFriends;
      filteredFriends = retrievedFriends;
    });
    _searchController.addListener(() {
      _filterFriends(_searchController.text);
    });
  }

  void _showAddFriendDialog() async {
    final newFriend = await showDialog<Friend?>(
      context: context,
      builder: (ctx) => AddFriendDialog(phoneController: _phoneController),
    );
    if (newFriend != null) {
      setState(() {
        myFriends?.add(newFriend);
        filteredFriends = myFriends;
      });
    }
  }

  void _filterFriends(String searchedFriend) {
    setState(() {
      filteredFriends = myFriends
          ?.where((friend) =>
              friend.name.toLowerCase().contains(searchedFriend.toLowerCase()))
          .toList();
    });
  }

  void _showCreateOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'What you want to create ?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                key: const Key('create_or_update_event'),
                icon: const Icon(Icons.event, color: Colors.white),
                label: const Text(
                  'Event',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => CreateOrUpdateEvent(
                        onAddEvent: (Event event) {},
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              ElevatedButton.icon(
                key: const Key('create_gift'),
                icon: const Icon(Icons.card_giftcard, color: Colors.white),
                label: const Text(
                  'Event & Gift',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 121, 215, 190),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (ctx) => const CreateOrUpdateEvent(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('home'),
      appBar: AppBar(
        title: Text(widget.user.name),
        actions: [
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (ctx) => const ProfileScreen(),
              ),
            ),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              key: const Key('choose_event_or_gift'),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => _showCreateOptionsDialog(context),
              child: const Text(
                'Create Your Own Event/List',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search Friends...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: myFriends == null
                ? const Center(child: CircularProgressIndicator())
                : filteredFriends!.isEmpty
                    ? const Center(child: Text('No friends found.'))
                    : ListView.builder(
                        itemCount: filteredFriends!.length,
                        itemBuilder: (context, index) {
                          final friend = filteredFriends![index];
                          return FriendItem(friend: friend);
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
