import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/friend_controller.dart';

class AddFriendDialog extends StatefulWidget {
  const AddFriendDialog({super.key, required this.phoneController});
  final TextEditingController phoneController;

  @override
  State<StatefulWidget> createState() => _AddFriendDialogState();
}

class _AddFriendDialogState extends State<AddFriendDialog> {
  var errorFound = false;
  void _addFriend(String phoneNumber) async {
    if (widget.phoneController.text.trim().isEmpty) {
      setState(() {
        errorFound = true;
      });
    } else {
      errorFound = false;
      final friend =
          await FriendController.addFriendsUsingPhoneNumber(phoneNumber);
      if (!mounted) return;
      Navigator.pop(context, friend);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friend != null
              ? 'Friend Added Successfully!'
              : 'Friend not found! Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final addedWiget = errorFound == false
        ? null
        : const Text(
            'Please Enter Valid Phone Number',
            style: TextStyle(color: Colors.red),
          );
    return AlertDialog(
      title: const Text('Add a Friend'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: widget.phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '01234567890',
              prefixIcon: Icon(Icons.phone),
            ),
          ),
          if (addedWiget != null) (addedWiget),
        ],
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () {
                widget.phoneController.clear();
                Navigator.pop(context, null);
              },
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 20),
            ElevatedButton(
              onPressed: () {
                _addFriend(widget.phoneController.text.trim());
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ],
    );
  }
}
