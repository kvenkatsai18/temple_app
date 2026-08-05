class EventModel {
  final String id;
  final String templeId;
  final String name;
  final String description;
  final DateTime eventDate;
  final String timing;
  final String location;
  final String? imageUrl;
  final bool isActive;
  final int? maxAttendees;
  final int attendeesCount;
  final DateTime? createdAt;

  EventModel({
    required this.id,
    required this.templeId,
    required this.name,
    required this.description,
    required this.eventDate,
    required this.timing,
    required this.location,
    this.imageUrl,
    this.isActive = true,
    this.maxAttendees,
    this.attendeesCount = 0,
    this.createdAt,
  });

  factory EventModel.fromFirestore(String id, Map<String, dynamic> data) {
    return EventModel(
      id: id,
      templeId: data['templeId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      eventDate: data['eventDate'] != null 
          ? DateTime.parse(data['eventDate'].toString())
          : DateTime.now(),
      timing: data['timing'] ?? '',
      location: data['location'] ?? '',
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      maxAttendees: data['maxAttendees'],
      attendeesCount: data['attendeesCount'] ?? 0,
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'templeId': templeId,
      'name': name,
      'description': description,
      'eventDate': eventDate.toIso8601String(),
      'timing': timing,
      'location': location,
      'imageUrl': imageUrl ?? '',
      'isActive': isActive,
      'maxAttendees': maxAttendees,
      'attendeesCount': attendeesCount,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
