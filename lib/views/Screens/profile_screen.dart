import 'package:flutter/material.dart';
import 'package:hedieaty/controllers/authentication_controller.dart';
import 'package:hedieaty/controllers/event_controller.dart';
import 'package:hedieaty/controllers/user_controller.dart';
import 'package:hedieaty/models/model/event.dart';
import 'package:hedieaty/models/model/user_model.dart';
import 'package:hedieaty/views/Screens/Auth/login_screen.dart';
import 'package:hedieaty/views/Screens/event_list_screen.dart';
import 'package:hedieaty/views/Screens/my_pledged_gifts_screen.dart';
import 'package:hedieaty/views/widgets/event_item.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  UserModel? currentUser;
  List<Event>? events;

  bool editing = false;
  bool notificationStatus = true;

  @override
  void initState() {
    super.initState();
    loadUser();
  }

  void loadUser() async {
    currentUser = await UserController.retrieveUserModel();
    if (currentUser != null) {
      events =
          await EventController.getEventList(currentUser!.firestoreId!, true);
      if (events == null || events!.isEmpty) {
        events = [];
      }
      setState(() {
        _nameController.text = currentUser!.name;
        _phoneNumberController.text = currentUser!.phoneNumber;
        _bioController.text = currentUser!.bio ?? '';
      });
    }
  }

  void _updateProfile() async {
    final updatedUser = await UserController.updateUserData(
        _nameController.text, _phoneNumberController.text, _bioController.text);
    if (updatedUser != null) {
      setState(() {
        currentUser = updatedUser;
        editing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile'),
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              setState(() {
                editing = !editing;
              });
            },
          ),
        ],
      ),
      body: currentUser == null && events == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const CircleAvatar(
                          radius: 60,
                          backgroundImage:
                              AssetImage('assets/images/male-avatar.png'),
                        ),
                        const SizedBox(height: 20),
                        if (editing)
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _nameController,
                                  decoration:
                                      const InputDecoration(labelText: 'Name'),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your Name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _phoneNumberController,
                                  decoration: const InputDecoration(
                                      labelText: 'Phone Number'),
                                  keyboardType: TextInputType.phone,
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your phone number';
                                    }
                                    if (num.tryParse(value) == null) {
                                      return 'Please enter a valid phone number';
                                    }
                                    if (value.length < 9) {
                                      return 'Phone number must be at least 9 numbers';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextFormField(
                                  controller: _bioController,
                                  decoration: const InputDecoration(
                                    labelText: 'Bio',
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Receive Notifications:',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    Switch(
                                      value: notificationStatus,
                                      activeColor: const Color.fromARGB(
                                          255, 41, 30, 113),
                                      onChanged: (value) {
                                        setState(() {
                                          notificationStatus = value;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton.icon(
                                    label: const Text('Update Profile'),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: const Color.fromARGB(
                                          255, 41, 30, 113),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                    ),
                                    onPressed: _updateProfile),
                              ],
                            ),
                          ),
                        if (!editing)
                          Column(
                            children: [
                              Text(currentUser!.name,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      )),
                              const SizedBox(height: 8),
                              Text(
                                currentUser!.bio ?? '',
                                style: const TextStyle(
                                  fontStyle: FontStyle.italic,
                                  color: Color.fromARGB(255, 104, 104, 104),
                                ),
                              ),
                            ],
                          ),
                        const SizedBox(height: 30),
                        const Divider(
                          color: Color.fromRGBO(224, 224, 224, 1),
                          thickness: 1,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ListTile(
                                leading: const Icon(
                                  Icons.event,
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                title: const Text(
                                  'My Events',
                                  style: TextStyle(fontSize: 18),
                                ),
                                onTap: () => currentUser?.firestoreId != null
                                    ? {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (ctx) => EventListScreen(
                                              userId: currentUser!.firestoreId!,
                                            ),
                                          ),
                                        )
                                      }
                                    : null),
                            ListTile(
                              leading: const Icon(
                                Icons.card_giftcard,
                                color: Colors.redAccent,
                                size: 30,
                              ),
                              title: const Text(
                                'My Pledged Gifts',
                                style: TextStyle(fontSize: 18),
                              ),
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) =>
                                      const MyPledgedGiftsScreen(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(
                            color: Color.fromRGBO(224, 224, 224, 1),
                            thickness: 1),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: events?.length ?? 0,
                          itemBuilder: (context, index) {
                            return EventItem(
                              event: events![index],
                              userId: currentUser?.firestoreId ?? '',
                              isCurrentUser: true,
                            );
                          },
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 20,
                      ),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () async {
                      await AuthController().logout();
                      if (!context.mounted) return;
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const LoginScreen()),
                        (route) => false,
                      );
                    },
                    icon: const Icon(Icons.logout_outlined),
                    label: const Text('Logout'),
                  ),
                ),
              ],
            ),
    );
  }
}
