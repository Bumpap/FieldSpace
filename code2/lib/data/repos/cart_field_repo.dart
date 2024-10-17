import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class CartFieldRepo extends GetxService {
  final String id;
  final String spname;
  final String image;
  final int price;
  final String sport_id;
  final String Time;
  final bool isBook;
  final String userID;
  final String DatePick;

  CartFieldRepo(
      {required this.id,
      required this.spname,
      required this.image,
      required this.price,
      required this.sport_id,
      required this.Time,
      required this.isBook,
      required this.userID,
      required this.DatePick});

  factory CartFieldRepo.fromFirestore(DocumentSnapshot doc) {
    return CartFieldRepo(
        id: doc.id,
        spname: doc['name'],
        image: doc['image'],
        price: doc['price'],
        sport_id: doc['sport_field_id'],
        Time: doc['time'],
        isBook: doc['isBook'],
        userID: doc['userID'],
        DatePick: doc['DatePick']);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sport_field_id': sport_id,
      'name': spname,
      'price': price,
      'time': Time,
      'userID': userID,
      'DatePick': DatePick
    };
  }

  factory CartFieldRepo.fromJson(Map<String, dynamic> json) {
    return CartFieldRepo(
        id: json['id'],
        sport_id: json['sport_id'],
        spname: json['name'],
        price: json['price'],
        Time: json['time'],
        image: json['image'],
        isBook: json['isBook'],
        userID: json['userID'],
        DatePick: json['DatePick']);
  }
}
