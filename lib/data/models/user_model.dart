class UserModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role; // 'super_admin', 'admin', 'user'
  final String? templeId; // For admins - which temple they manage

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.templeId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      role: map['role'] ?? 'user',
      templeId: map['templeId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role,
      'templeId': templeId,
    };
  }

  bool get isSuperAdmin => role == 'super_admin';
  bool get isTempleAdmin => role == 'admin';
  bool get isUser => role == 'user';
}

class TempleModel {
  final String id;
  final String name;
  final String location;
  final String deity;
  final String? imageUrl;
  final String? adminId; // ID of the temple admin
  final bool isActive;
  final DateTime createdAt;

  TempleModel({
    required this.id,
    required this.name,
    required this.location,
    required this.deity,
    this.imageUrl,
    this.adminId,
    this.isActive = true,
    required this.createdAt,
  });

  factory TempleModel.fromMap(Map<String, dynamic> map) {
    return TempleModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      location: map['location'] ?? '',
      deity: map['deity'] ?? '',
      imageUrl: map['imageUrl'],
      adminId: map['adminId'],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null 
          ? DateTime.parse(map['createdAt']) 
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'deity': deity,
      'imageUrl': imageUrl,
      'adminId': adminId,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
