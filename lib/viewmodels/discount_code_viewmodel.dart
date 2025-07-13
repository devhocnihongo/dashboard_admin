import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/discount_code_model.dart';

class DiscountCodeViewModel extends ChangeNotifier {
  List<DiscountCodeModel> discountCodes = [];
  bool isLoading = false;

  DiscountCodeViewModel() {
    fetchDiscountCodes();
  }

  Future<void> fetchDiscountCodes() async {
    isLoading = true;
    notifyListeners();
    final snapshot = await FirebaseFirestore.instance.collection('discount_codes').get();
    discountCodes = snapshot.docs
        .map((doc) => DiscountCodeModel.fromJson(doc.id, doc.data()))
        .toList();
    isLoading = false;
    notifyListeners();
  }

  Future<void> addDiscountCode(DiscountCodeModel code) async {
    final ref = FirebaseFirestore.instance.collection('discount_codes').doc();
    await ref.set(code.toJson());
    await fetchDiscountCodes();
  }

  Future<void> updateDiscountCode(DiscountCodeModel code) async {
    await FirebaseFirestore.instance.collection('discount_codes').doc(code.id).update(code.toJson());
    await fetchDiscountCodes();
  }

  Future<void> deleteDiscountCode(String id) async {
    await FirebaseFirestore.instance.collection('discount_codes').doc(id).delete();
    await fetchDiscountCodes();
  }
}