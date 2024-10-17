import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../repos/checkout_repo.dart';

class ApiCheckout extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CheckoutRepo>> getAllData() async {
    try {
      QuerySnapshot snapshot =
          await _firestore.collection('checkout_history_order').get();
      return snapshot.docs
          .map((doc) => CheckoutRepo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching data from Firestore: $e');
    }
  }

  Future<List<CheckoutRepo>> getData(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('checkout_history_order')
          .where('userID', isEqualTo: userId)
          .get();
      return snapshot.docs
          .map((doc) => CheckoutRepo.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Error fetching data from Firestore: $e');
    }
  }
}
