import 'dart:convert';

class UserModel {
  int? id;
  String? firestoreId;
  final String name;
  final String email;
  final String phoneNumber;
  String? bio;
  Map<String, dynamic>? preferences;
  String? fcmToken;

  UserModel({
    this.id,
    this.bio,
    this.firestoreId,
    this.preferences,
    this.fcmToken,
    required this.name,
    required this.email,
    required this.phoneNumber,
  });

  //convert from UserObject to Local Database_Map
  Map<String, dynamic> toLocalMap() {
    return {
      'id': id,
      'firestore_id': firestoreId,
      'phone_number': phoneNumber,
      'name': name,
      'email': email,
      'bio': bio,
      'preferences': preferences != null ? jsonEncode(preferences) : null,
    };
  }

  // Convert from Local Database_Map to UserObject
  static UserModel fromLocalMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'],
      name: map['name'],
      email: map['email'],
      phoneNumber: map['phone_number'],
      firestoreId: map['firestore_id'],
      bio: map['bio'],
      preferences:
          map['preferences'] != null ? jsonDecode(map['preferences']) : null,
    );
  }

  //convert from UserObject to FireBase_Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'fcmToken': fcmToken,
      'preferences': preferences != null ? jsonEncode(preferences) : null,
    };
  }

  //convert from FireBase_Map to UserObject
  static UserModel fromMap(Map<String, dynamic> map, String documentId) {
    return UserModel(
      firestoreId: documentId,
      phoneNumber: map['phoneNumber'],
      name: map['name'],
      email: map['email'],
      bio: map['bio'],
      fcmToken: map['fcmToken'],
      preferences:
          map['preferences'] != null ? jsonDecode(map['preferences']) : null,
    );
  }
}
