import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CategoriesSportRepo extends GetxService {
  final String id;
  final String spname;
  final String image;

  CategoriesSportRepo(
      {required this.id, required this.spname, required this.image});

  factory CategoriesSportRepo.fromFirestore(DocumentSnapshot doc) {
    return CategoriesSportRepo(
      id: doc.id,
      spname: doc['name'],
      image: doc['image'],
    );
  }
}
