import 'package:cloud_firestore/cloud_firestore.dart';

class DarshanModel {
  final String id;
  final String visitorId;
  final String visitorName;
  final String phone;
  final String date;
  final String slot;
  final int numberOfPeople;
  final String? purpose;
  final String status; // scheduled, completed, cancelled
  final DateTime createdAt;

  DarshanModel({
    required this.id,
    required this.visitorId,
    required this.visitorName,
    required this.phone,
    required this.date,
    required this.slot,
    required this.numberOfPeople,
    this.purpose,
    required this.status,
    required this.createdAt,
  });

  factory DarshanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DarshanModel(
      id: doc.id,
      visitorId: data['visitorId'] ?? '',
      visitorName: data['visitorName'] ?? '',
      phone: data['phone'] ?? '',
      date: data['date'] ?? '',
      slot: data['slot'] ?? '',
      numberOfPeople: data['numberOfPeople'] ?? 1,
      purpose: data['purpose'],
      status: data['status'] ?? 'scheduled',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'visitorId': visitorId,
      'visitorName': visitorName,
      'phone': phone,
      'date': date,
      'slot': slot,
      'numberOfPeople': numberOfPeople,
      'purpose': purpose,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DarshanModel copyWith({
    String? id,
    String? visitorId,
    String? visitorName,
    String? phone,
    String? date,
    String? slot,
    int? numberOfPeople,
    String? purpose,
    String? status,
    DateTime? createdAt,
  }) {
    return DarshanModel(
      id: id ?? this.id,
      visitorId: visitorId ?? this.visitorId,
      visitorName: visitorName ?? this.visitorName,
      phone: phone ?? this.phone,
      date: date ?? this.date,
      slot: slot ?? this.slot,
      numberOfPeople: numberOfPeople ?? this.numberOfPeople,
      purpose: purpose ?? this.purpose,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
