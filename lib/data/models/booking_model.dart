class BookingModel {
  final String id;
  final String userId;
  final String templeId;
  final String type; // 'pooja' or 'darshan'
  final String poojaId;
  final String poojaName;
  final DateTime bookingDate;
  final String timing;
  final double amount;
  final String status; // 'pending', 'confirmed', 'completed', 'cancelled'
  final String? specialRequests;
  final String? name;
  final String? phone;
  final String? email;
  final DateTime? createdAt;

  BookingModel({
    required this.id,
    required this.userId,
    required this.templeId,
    required this.type,
    required this.poojaId,
    required this.poojaName,
    required this.bookingDate,
    required this.timing,
    required this.amount,
    this.status = 'pending',
    this.specialRequests,
    this.name,
    this.phone,
    this.email,
    this.createdAt,
  });

  factory BookingModel.fromFirestore(String id, Map<String, dynamic> data) {
    return BookingModel(
      id: id,
      userId: data['userId'] ?? '',
      templeId: data['templeId'] ?? '',
      type: data['type'] ?? 'pooja',
      poojaId: data['poojaId'] ?? '',
      poojaName: data['poojaName'] ?? '',
      bookingDate: data['bookingDate'] != null 
          ? DateTime.parse(data['bookingDate'].toString())
          : DateTime.now(),
      timing: data['timing'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      status: data['status'] ?? 'pending',
      specialRequests: data['specialRequests'],
      name: data['name'],
      phone: data['phone'],
      email: data['email'],
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'templeId': templeId,
      'type': type,
      'poojaId': poojaId,
      'poojaName': poojaName,
      'bookingDate': bookingDate.toIso8601String(),
      'timing': timing,
      'amount': amount,
      'status': status,
      'specialRequests': specialRequests ?? '',
      'name': name ?? '',
      'phone': phone ?? '',
      'email': email ?? '',
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
