import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/address.dart';

class LocationRepo {
  final String id;
  final String userID;
  String? sport_field_id;
  final List<Address> addresses;

  LocationRepo(
      {required this.userID,
      required this.addresses,
      this.sport_field_id,
      required this.id});

  factory LocationRepo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<Address> addressList = [];
    if (data['addresses'] != null) {
      addressList = (data['addresses'] as List<dynamic>)
          .map((itemData) => Address.fromJson(itemData as Map<String, dynamic>))
          .toList();
    }

    return LocationRepo(
      id: doc.id,
      userID: data['userID'] ?? '',
      sport_field_id: data['sport_field_id'] ?? '',
      addresses: addressList,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
      'sport_field_id': sport_field_id,
      'addresses': addresses.map((a) => a.toJson()).toList(),
    };
  }
}
