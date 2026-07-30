import 'package:cloud_firestore/cloud_firestore.dart';

class AnnouncementModel {
  final String id;
  final String title;
  final String message;
  final String type; // info, important, event
  final bool isActive;
  final DateTime? validUntil;
  final DateTime createdAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    this.isActive = true,
    this.validUntil,
    required this.createdAt,
  });

  factory AnnouncementModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AnnouncementModel(
      id: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'info',
      isActive: data['isActive'] ?? true,
      validUntil: (data['validUntil'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'isActive': isActive,
      'validUntil': validUntil != null ? Timestamp.fromDate(validUntil!) : null,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  AnnouncementModel copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isActive,
    DateTime? validUntil,
    DateTime? createdAt,
  }) {
    return AnnouncementModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isActive: isActive ?? this.isActive,
      validUntil: validUntil ?? this.validUntil,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
