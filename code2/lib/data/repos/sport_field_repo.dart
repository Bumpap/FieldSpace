import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class SportFieldRepo extends GetxService {
  final String id;
  final String spname;
  final String image;
  final String address;
  final String author;
  final String authorURL;
  final String openDay;
  final Timestamp openTime;
  final Timestamp closeTime;
  final String phoneNumber;
  final int price;
  final String categories;

  SportFieldRepo({
    required this.id,
    required this.spname,
    required this.image,
    required this.address,
    required this.author,
    required this.openDay,
    required this.authorURL,
    required this.openTime,
    required this.closeTime,
    required this.phoneNumber,
    required this.price,
    required this.categories,
  });

  factory SportFieldRepo.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;

    DateTime today = DateTime.now();

    Timestamp openTime;
    if (data['openTime'] is String) {
      openTime = Timestamp.fromDate(DateTime.parse(data['openTime']));
    } else {
      openTime = data['openTime'] ?? Timestamp.now();
    }
    DateTime openDateTime = openTime.toDate();
    if (openDateTime.year != today.year ||
        openDateTime.month != today.month ||
        openDateTime.day != today.day) {
      openTime = Timestamp.fromDate(DateTime(today.year, today.month, today.day,
          openDateTime.hour, openDateTime.minute));
      FirebaseFirestore.instance.collection('sportfield').doc(doc.id).update({
        'openTime': openTime,
      });
    }

    Timestamp closeTime;
    if (data['closeTime'] is String) {
      closeTime = Timestamp.fromDate(DateTime.parse(data['closeTime']));
    } else {
      closeTime = data['closeTime'] ?? Timestamp.now();
    }
    DateTime closeDateTime = closeTime.toDate();
    if (closeDateTime.year != today.year ||
        closeDateTime.month != today.month ||
        closeDateTime.day != today.day) {
      closeTime = Timestamp.fromDate(DateTime(today.year, today.month,
          today.day, closeDateTime.hour, closeDateTime.minute));
      FirebaseFirestore.instance.collection('sportfield').doc(doc.id).update({
        'closeTime': closeTime,
      });
    }

    return SportFieldRepo(
      id: doc.id,
      spname: data['name'] ?? '',
      image: data['image'] ?? '',
      address: data['address'] ?? '',
      author: data['author'] ?? '',
      authorURL: data['authorURL'] ?? '',
      openDay: data['openDay'] ?? '',
      openTime: openTime,
      closeTime: closeTime,
      phoneNumber: data['phonenumber'] ?? '',
      price: int.tryParse(data['price']?.toString() ?? '0') ?? 0,
      categories: doc['cateID'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': spname,
      'image': image,
      'address': address,
      'author': author,
      'authorURL': authorURL,
      'openDay': openDay,
      'openTime': openTime,
      'closeTime': closeTime,
      'phonenumber': phoneNumber,
      'price': price,
      'cateID': categories,
    };
  }
}
