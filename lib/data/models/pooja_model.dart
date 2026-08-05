class PoojaModel {
  final String id;
  final String templeId;
  final String name;
  final String description;
  final String timing;
  final double price;
  final int duration; // in minutes
  final String? imageUrl;
  final bool isActive;
  final int availableSlots;
  final int bookedSlots;
  final DateTime? createdAt;

  PoojaModel({
    required this.id,
    required this.templeId,
    required this.name,
    required this.description,
    required this.timing,
    required this.price,
    this.duration = 60,
    this.imageUrl,
    this.isActive = true,
    this.availableSlots = 50,
    this.bookedSlots = 0,
    this.createdAt,
  });

  factory PoojaModel.fromFirestore(String id, Map<String, dynamic> data) {
    return PoojaModel(
      id: id,
      templeId: data['templeId'] ?? '',
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      timing: data['timing'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      duration: data['duration'] ?? 60,
      imageUrl: data['imageUrl'],
      isActive: data['isActive'] ?? true,
      availableSlots: data['availableSlots'] ?? 50,
      bookedSlots: data['bookedSlots'] ?? 0,
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
      'timing': timing,
      'price': price,
      'duration': duration,
      'imageUrl': imageUrl ?? '',
      'isActive': isActive,
      'availableSlots': availableSlots,
      'bookedSlots': bookedSlots,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
