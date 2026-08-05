class DonationModel {
  final String id;
  final String userId;
  final String templeId;
  final String donorName;
  final String? donorEmail;
  final String? donorPhone;
  final double amount;
  final String type; // 'general', 'hundi', 'annadan', 'seva'
  final String? purpose;
  final String? message;
  final String status; // 'pending', 'completed', 'failed', 'refunded'
  final DateTime? createdAt;

  DonationModel({
    required this.id,
    required this.userId,
    required this.templeId,
    required this.donorName,
    this.donorEmail,
    this.donorPhone,
    required this.amount,
    this.type = 'general',
    this.purpose,
    this.message,
    this.status = 'completed',
    this.createdAt,
  });

  factory DonationModel.fromFirestore(String id, Map<String, dynamic> data) {
    return DonationModel(
      id: id,
      userId: data['userId'] ?? '',
      templeId: data['templeId'] ?? '',
      donorName: data['donorName'] ?? '',
      donorEmail: data['donorEmail'],
      donorPhone: data['donorPhone'],
      amount: (data['amount'] ?? 0).toDouble(),
      type: data['type'] ?? 'general',
      purpose: data['purpose'],
      message: data['message'],
      status: data['status'] ?? 'completed',
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'templeId': templeId,
      'donorName': donorName,
      'donorEmail': donorEmail ?? '',
      'donorPhone': donorPhone ?? '',
      'amount': amount,
      'type': type,
      'purpose': purpose ?? '',
      'message': message ?? '',
      'status': status,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
