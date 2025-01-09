class Friend {
  final int? id; // table Id
  final String? userId; // User Firestore_id
  final String? friendId; // Friend Firestore_id
  final String name;

  Friend({
    this.id,
    this.friendId,
    this.userId,
    required this.name,
  });

  //convert from FriendObject to FireBase_Map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'friendId': friendId,
      'name': name,
    };
  }

  //convert from FireBase_Map to FriendObject
  static Friend fromMap(Map<String, dynamic> map) {
    return Friend(
      userId: map['userId'],
      friendId: map['friendId'],
      name: map['name'],
    );
  }

  //convert from FriendObject to Local Database_Map
  Map<String, dynamic> toLocalMap() {
    return {
      'user_firestore_id': userId,
      'friend_firestore_id': friendId,
      'name': name,
    };
  }

  //convert from Local Database_Map to FriendObject
  static Friend fromLocalMap(Map<String, dynamic> map) {
    return Friend(
      id: map['id'],
      userId: map['user_firestore_id'],
      friendId: map['friend_firestore_id'],
      name: map['name'],
    );
  }
}
