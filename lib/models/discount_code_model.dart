import 'package:cloud_firestore/cloud_firestore.dart';

class DiscountCodeModel {
  final String id;
  final String code;
  final String creatorRole;
  final String discountType;
  final DateTime expiredDate;
  final int limit;
  final int minOrder;
  final String? promotionId;
  final DateTime startDate;
  final String? storeId;
  final int used;
  final int value;

  DiscountCodeModel({
    required this.id,
    required this.code,
    required this.creatorRole,
    required this.discountType,
    required this.expiredDate,
    required this.limit,
    required this.minOrder,
    this.promotionId,
    required this.startDate,
    this.storeId,
    required this.used,
    required this.value,
  });

  factory DiscountCodeModel.fromJson(String id, Map<String, dynamic> data) {
    return DiscountCodeModel(
      id: id,
      code: data['code'] ?? '',
      creatorRole: data['creatorRole'] ?? '',
      discountType: data['discountType'] ?? '',
      expiredDate: _parseDate(data['expiredDate']),
      limit: (data['limit'] as num?)?.toInt() ?? 0,
      minOrder: (data['minOrder'] as num?)?.toInt() ?? 0,
      promotionId: data['promotionId'],
      startDate: _parseDate(data['startDate']),
      storeId: data['storeId'],
      used: (data['used'] as num?)?.toInt() ?? 0,
      value: (data['value'] as num?)?.toInt() ?? 0,
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is Timestamp) return date.toDate();
    if (date is String) {
      try {
        return DateTime.parse(date);
      } catch (e) {
        return DateTime.now();
      }
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'creatorRole': creatorRole,
      'discountType': discountType,
      'expiredDate': expiredDate,
      'limit': limit,
      'minOrder': minOrder,
      'promotionId': promotionId,
      'startDate': startDate,
      'storeId': storeId,
      'used': used,
      'value': value,
    };
  }
}