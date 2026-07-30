import 'package:cloud_firestore/cloud_firestore.dart';

class PoojaModel {
  final String id;
  final String name;
  final String description;
  final String poojaType;
  final double amount;
  final String timing;
  final List<String> days; // Days when this pooja is performed
  final String? deity;
  final String? imageUrl;
  final bool isActive;
  final int availableSlots;
  final DateTime createdAt;
  final DateTime? updatedAt;

  PoojaModel({
    required this.id,
    required this.name,
    required this.description,
    required this.poojaType,
    required this.amount,
    required this.timing,
    required this.days,
    this.deity,
    this.imageUrl,
    this.isActive = true,
    this.availableSlots = 10,
    required this.createdAt,
    this.updatedAt,
  });

  factory PoojaModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PoojaModel(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      poojaType: data['poojaType'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      timing: data['timing'] ?? '',
      days: List<String>.from(data['days'] ?? []),
      deity: data['deity'],
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      availableSlots: data['availableSlots'] ?? 10,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'poojaType': poojaType,
      'amount': amount,
      'timing': timing,
      'days': days,
      'deity': deity,
      'imageUrl': imageUrl,
      'isActive': isActive,
      'availableSlots': availableSlots,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  PoojaModel copyWith({
    String? id,
    String? name,
    String? description,
    String? poojaType,
    double? amount,
    String? timing,
    List<String>? days,
    String? deity,
    String? imageUrl,
    bool? isActive,
    int? availableSlots,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PoojaModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      poojaType: poojaType ?? this.poojaType,
      amount: amount ?? this.amount,
      timing: timing ?? this.timing,
      days: days ?? this.days,
      deity: deity ?? this.deity,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      availableSlots: availableSlots ?? this.availableSlots,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
