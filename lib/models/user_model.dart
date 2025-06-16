class UserModel {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String email;
  final String role;
  final bool status;
  final DateTime? createdAt;

  UserModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.email,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory UserModel.fromJson(String id, Map<String, dynamic> data) {
    return UserModel(
      id: id,
      userId: data['userId']?.toString() ?? '',
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'] ?? '',
      role: data['role'] ?? '',
      status: data['status'] is bool
          ? data['status']
          : (data['status'] is String
          ? data['status'].toLowerCase() == 'true'
          : false),
      createdAt: data['createdAt'] != null && data['createdAt'] is DateTime
          ? data['createdAt']
          : null,
    );
  }
}