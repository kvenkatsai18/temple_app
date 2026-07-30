import 'package:cloud_firestore/cloud_firestore.dart';

class DonationModel {
  final String id;
  final String donorId;
  final String donorName;
  final String category;
  final double amount;
  final String? purpose;
  final String paymentMethod;
  final String status; // pending, completed, failed
  final DateTime donationDate;
  final String? transactionId;
  final String? message;
  final DateTime createdAt;

  DonationModel({
    required this.id,
    required this.donorId,
    required this.donorName,
    required this.category,
    required this.amount,
    this.purpose,
    required this.paymentMethod,
    required this.status,
    required this.donationDate,
    this.transactionId,
    this.message,
    required this.createdAt,
  });

  factory DonationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DonationModel(
      id: doc.id,
      donorId: data['donorId'] ?? '',
      donorName: data['donorName'] ?? '',
      category: data['category'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      purpose: data['purpose'],
      paymentMethod: data['paymentMethod'] ?? '',
      status: data['status'] ?? 'pending',
      donationDate: (data['donationDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionId: data['transactionId'],
      message: data['message'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'donorId': donorId,
      'donorName': donorName,
      'category': category,
      'amount': amount,
      'purpose': purpose,
      'paymentMethod': paymentMethod,
      'status': status,
      'donationDate': Timestamp.fromDate(donationDate),
      'transactionId': transactionId,
      'message': message,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  DonationModel copyWith({
    String? id,
    String? donorId,
    String? donorName,
    String? category,
    double? amount,
    String? purpose,
    String? paymentMethod,
    String? status,
    DateTime? donationDate,
    String? transactionId,
    String? message,
    DateTime? createdAt,
  }) {
    return DonationModel(
      id: id ?? this.id,
      donorId: donorId ?? this.donorId,
      donorName: donorName ?? this.donorName,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      purpose: purpose ?? this.purpose,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      status: status ?? this.status,
      donationDate: donationDate ?? this.donationDate,
      transactionId: transactionId ?? this.transactionId,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
