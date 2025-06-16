class StoreModel {
  final String id;
  final String name;
  final String ownerId;
  final bool isVerified;

  StoreModel({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.isVerified,
  });

  factory StoreModel.fromJson(String id, Map<String, dynamic> data) {
    return StoreModel(
      id: id,
      name: data['name'] ?? '',
      ownerId: data['ownerId'] ?? '',
      isVerified: data['isVerified'] is bool
          ? data['isVerified']
          : (data['isVerified'] is String
          ? data['isVerified'].toLowerCase() == 'true'
          : false),
    );
  }
}