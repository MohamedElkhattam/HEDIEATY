enum Category { holiday, wedding, concert, birthday, graduation, engagement }

class Event {
  int? localId;           // Local Id foreign key
  String? id;             // FireStore Id
  String? eventOwnerId;   // FireStore UserId
  int? eventOwnerLocalId; // Local userId foreign key
  String name;
  DateTime date;
  String location;
  String description;
  Category category;

  Event({
    this.id,
    this.eventOwnerId,
    this.localId,
    this.eventOwnerLocalId,
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.category,
  });

  //convert from EventObject to FireBase_Map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'category': category.name,
      'eventOwnerId': eventOwnerId,
    };
  }

  //convert from FireBase_Map to EventModel
  static Event fromMap(Map<String, dynamic> map, String documentId) {
    return Event(
      id: documentId,
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      category: Category.values.byName(map['category']),
      eventOwnerId: map['eventOwnerId'],
    );
  }

  //convert from EventObject to Local Database_Map
  Map<String, dynamic> toLocalMap() {
    return {
      'firestore_id': id,
      'event_owner_firestore_id': eventOwnerId,
      'event_owner_id': eventOwnerLocalId,
      'name': name,
      'date': date.toIso8601String(),
      'location': location,
      'description': description,
      'category': category.name,
    };
  }

  // Convert from Local Database_Map to EventObject
  static Event fromLocalMap(Map<String, dynamic> map) {
    return Event(
      id: map['firestore_id'],
      eventOwnerId: map['event_owner_firestore_id'],
      localId: map['local_id'],
      eventOwnerLocalId: map['event_owner_id'],
      name: map['name'],
      date: DateTime.parse(map['date']),
      location: map['location'],
      description: map['description'],
      category: Category.values.byName(map['category']),
    );
  }
}
