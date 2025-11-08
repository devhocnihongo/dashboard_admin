import 'package:cloud_firestore/cloud_firestore.dart';

class Commission {
  final String id;
  final String storeId;
  final String storeName;
  final int commissionAmount;
  final String status;
  final DateTime dueDate;
  final DateTime createdAt;
  final DateTime? paidDate;
  final int orderAmount;
  final List<String> orderIds;
  final String? adminNote;
  final String? paymentProof;

  Commission({
    required this.id,
    required this.storeId,
    required this.storeName,
    required this.commissionAmount,
    required this.status,
    required this.dueDate,
    required this.createdAt,
    this.paidDate,
    required this.orderAmount,
    required this.orderIds,
    this.adminNote,
    this.paymentProof,
  });

  factory Commission.fromMap(String id, Map<String, dynamic> data) {
    return Commission(
      id: id,
      storeId: data['storeId'] ?? '',
      storeName: data['storeName'] ?? '',
      commissionAmount: (data['commissionAmount'] as num?)?.toInt() ?? 0,
      status: data['status'] ?? 'waiting',
      dueDate: (data['dueDate'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      paidDate: data['paidDate'] != null
          ? (data['paidDate'] as Timestamp).toDate()
          : null,
      orderAmount: (data['orderAmount'] as num?)?.toInt() ?? 0,
      orderIds: (data['orderIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList() ??
          [],
      adminNote: data['adminNote'],
      paymentProof: data['paymentProof'],
    );
  }
}