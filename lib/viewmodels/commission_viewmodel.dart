import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/commission_model.dart';

class CommissionViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'commissions';

  Stream<List<Commission>> get waitingCommissionsStream {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'waiting')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Commission.fromMap(doc.id, doc.data()))
        .toList());
  }

  Stream<Map<String, List<Commission>>> get waitingCommissionsByStoreStream {
    return waitingCommissionsStream.map((commissions) {
      final Map<String, List<Commission>> grouped = {};
      for (var com in commissions) {
        if (grouped.containsKey(com.storeName)) {
          grouped[com.storeName]!.add(com);
        } else {
          grouped[com.storeName] = [com];
        }
      }
      return grouped;
    });
  }

  Stream<int> get totalRevenueStream {
    return _firestore
        .collection(_collection)
        .where('status', isEqualTo: 'paid')
        .snapshots()
        .map((snapshot) {
      int total = 0;
      for (var doc in snapshot.docs) {
        total += (doc.data()['commissionAmount'] as num?)?.toInt() ?? 0;
      }
      return total;
    });
  }

  Future<void> confirmPayment(String commissionId) async {
    try {
      await _firestore.collection(_collection).doc(commissionId).update({
        'status': 'paid',
        'paidDate': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      debugPrint('Lỗi xác nhận thanh toán: $e');
      rethrow;
    }
  }
}