import 'package:flutter/material.dart';

enum Status { available, pledged, purchased }

Map statusIcon = {
  Status.available: const Icon(Icons.check_circle, color: Colors.green),
  Status.pledged: const Icon(Icons.handshake, color: Colors.blue),
  Status.purchased: const Icon(Icons.shopping_cart, color: Colors.red),
};

class Gift {
  String? id; // giftfirestore id
  final String? pledgedBy; // pledgedBy Firestore id
  String? eventId; //event Firestore
  int? localId; // gift Local Id
  int? evenLocalId; // event  Local foreign key
  Status status;
  String name;
  String category;
  double price;
  String description;
  String? imagePath;
  String giftOwnerName;

  Gift({
    this.id,
    this.pledgedBy,
    this.eventId,
    this.localId,
    this.evenLocalId,
    required this.name,
    required this.category,
    required this.price,
    required this.description,
    this.status = Status.available,
    required this.giftOwnerName,
    this.imagePath,
  });

  //convert from GiftObject to FireBase_Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'eventId': eventId,
      'status': status.name,
      'giftOwnerName': giftOwnerName,
      'imagePath': imagePath,
      'pledgedBy': pledgedBy,
    };
  }

  //convert from FireBase_Map to GiftObject
  static Gift fromMap(Map<String, dynamic> map, String documentId) {
    return Gift(
      id: documentId,
      name: map['name'],
      category: map['category'],
      price: map['price']?.toDouble(),
      description: map['description'],
      eventId: map['eventId'],
      status: Status.values.byName(map['status']),
      giftOwnerName: map['giftOwnerName'],
      imagePath: map['imagePath'],
      pledgedBy: map['pledgedBy'],
    );
  }

  //convert from GiftObject to Local Database_Map
  Map<String, dynamic> toLocalMap() {
    return {
      'firestore_id': id,
      'pledged_by': pledgedBy,
      'event_id': eventId,
      'gift_ownername': giftOwnerName,
      'event_local_id': evenLocalId,
      'name': name,
      'category': category,
      'price': price,
      'description': description,
      'status': status.name,
      'image_path': imagePath,
    };
  }

  // Convert from Local Database_Map to GiftObject
  static Gift fromLocalMap(Map<String, dynamic> map) {
    return Gift(
      id: map['firestore_id'],
      localId: map['local_id'],
      pledgedBy: map['pledged_by'],
      eventId: map['event_id'],
      giftOwnerName: map['gift_ownername'],
      evenLocalId: map['event_local_id'],
      name: map['name'],
      category: map['category'],
      price: map['price']?.toDouble(),
      description: map['description'],
      status: Status.values.byName(map['status']),
      imagePath: map['image_path'],
    );
  }
}
