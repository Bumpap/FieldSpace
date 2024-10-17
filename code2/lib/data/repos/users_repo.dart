import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class UsersRepo extends GetxService {
  final String id;
  final String email;
  final String password;
  final String name;
  final String phoneNb;
  final String imagePro;
  final String role;

  UsersRepo(
      {required this.id,
      required this.email,
      required this.password,
      required this.name,
      required this.phoneNb,
      required this.imagePro,
      required this.role});

  factory UsersRepo.fromFirestore(DocumentSnapshot doc) {
    return UsersRepo(
        id: doc.id,
        email: doc['email'],
        password: doc['password'],
        name: doc['name'],
        phoneNb: doc['phonenumber'],
        imagePro: doc['image'],
        role: doc['role']);
  }
}
