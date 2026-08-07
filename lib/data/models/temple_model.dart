class TempleModel {
  final String id;
  final String name;
  final String location;
  final String? deity;
  final String? imageUrl;
  final String? description;
  final String? address;
  final String? phone;
  final String? email;
  final bool isActive;
  final DateTime? createdAt;
  final String? liveStreamUrl;
  final bool isLive;
  final Map<String, dynamic>? timings;

  TempleModel({
    required this.id,
    required this.name,
    required this.location,
    this.deity,
    this.imageUrl,
    this.description,
    this.address,
    this.phone,
    this.email,
    this.isActive = true,
    this.createdAt,
    this.liveStreamUrl,
    this.isLive = false,
    this.timings,
  });

  factory TempleModel.fromFirestore(String id, Map<String, dynamic> data) {
    return TempleModel(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      deity: data['deity'],
      imageUrl: data['imageUrl'],
      description: data['description'],
      address: data['address'],
      phone: data['phone'],
      email: data['email'],
      isActive: data['isActive'] ?? true,
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
      liveStreamUrl: data['liveStreamUrl'],
      isLive: data['isLive'] ?? false,
      timings: data['timings'] != null 
          ? Map<String, dynamic>.from(data['timings'])
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'location': location,
      'deity': deity ?? '',
      'imageUrl': imageUrl ?? '',
      'description': description ?? '',
      'address': address ?? '',
      'phone': phone ?? '',
      'email': email ?? '',
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
      'liveStreamUrl': liveStreamUrl ?? '',
      'isLive': isLive,
      'timings': timings ?? {},
    };
  }
}
