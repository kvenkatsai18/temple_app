import 'package:cloud_firestore/cloud_firestore.dart';

class EventModel {
  final String id;
  final String title;
  final String description;
  final DateTime eventDate;
  final String timing;
  final String? venue;
  final String? imageUrl;
  final bool isSpecialEvent;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.eventDate,
    required this.timing,
    this.venue,
    this.imageUrl,
    this.isSpecialEvent = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      eventDate: (data['eventDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      timing: data['timing'] ?? '',
      venue: data['venue'],
      imageUrl: data['imageUrl'],
      isSpecialEvent: data['isSpecialEvent'] ?? false,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'eventDate': Timestamp.fromDate(eventDate),
      'timing': timing,
      'venue': venue,
      'imageUrl': imageUrl,
      'isSpecialEvent': isSpecialEvent,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  EventModel copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? eventDate,
    String? timing,
    String? venue,
    String? imageUrl,
    bool? isSpecialEvent,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EventModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      eventDate: eventDate ?? this.eventDate,
      timing: timing ?? this.timing,
      venue: venue ?? this.venue,
      imageUrl: imageUrl ?? this.imageUrl,
      isSpecialEvent: isSpecialEvent ?? this.isSpecialEvent,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
