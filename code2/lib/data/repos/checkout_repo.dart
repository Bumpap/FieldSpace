import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../../models/Item.dart';

class CheckoutRepo extends GetxService {
  final String id;
  final List<Item> items;
  final int totalPrice;
  final Timestamp? timestamp;
  final String userID;

  CheckoutRepo(
      {required this.id,
      required this.items,
      required this.totalPrice,
      this.timestamp,
      required this.userID});

  factory CheckoutRepo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<Item> itemList = [];
    if (data['items'] != null) {
      itemList = (data['items'] as List<dynamic>)
          .map((itemData) => Item.fromJson(itemData as Map<String, dynamic>))
          .toList();
    }

    return CheckoutRepo(
        id: doc.id,
        items: itemList,
        totalPrice: (data['totalPrice'] ?? 0).toInt(),
        timestamp: data['timestamp'] as Timestamp?,
        userID: data['userID'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'timestamp': timestamp ?? FieldValue.serverTimestamp(),
      'userID': userID
    };
  }
}
