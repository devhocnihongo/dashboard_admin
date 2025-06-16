class ProductModel {
  final String id;
  final String name;
  final String storeId;
  final String status;

  ProductModel({
    required this.id,
    required this.name,
    required this.storeId,
    required this.status,
  });

  factory ProductModel.fromJson(String id, Map<String, dynamic> data) {
    return ProductModel(
      id: id,
      name: data['name'] ?? '',
      storeId: data['storeId'] ?? '',
      status: data['status'] ?? '',
    );
  }
}