import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/data/repos/categories_sport_repo.dart';
import 'package:get/get.dart';

class ApiCategories extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CategoriesSportRepo>> getData() async {
    QuerySnapshot snapshot = await _firestore.collection('categories').get();
    return snapshot.docs
        .map((doc) => CategoriesSportRepo.fromFirestore(doc))
        .toList();
  }
}
