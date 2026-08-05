class AnnouncementModel {
  final String id;
  final String templeId;
  final String title;
  final String message;
  final String type; // 'general', 'event', 'alert', 'maintenance'
  final bool isActive;
  final DateTime? validUntil;
  final DateTime? createdAt;

  AnnouncementModel({
    required this.id,
    required this.templeId,
    required this.title,
    required this.message,
    this.type = 'general',
    this.isActive = true,
    this.validUntil,
    this.createdAt,
  });

  factory AnnouncementModel.fromFirestore(String id, Map<String, dynamic> data) {
    return AnnouncementModel(
      id: id,
      templeId: data['templeId'] ?? '',
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      type: data['type'] ?? 'general',
      isActive: data['isActive'] ?? true,
      validUntil: data['validUntil'] != null 
          ? DateTime.tryParse(data['validUntil'].toString())
          : null,
      createdAt: data['createdAt'] != null 
          ? DateTime.tryParse(data['createdAt'].toString())
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'templeId': templeId,
      'title': title,
      'message': message,
      'type': type,
      'isActive': isActive,
      'validUntil': validUntil?.toIso8601String(),
      'createdAt': createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }
}
