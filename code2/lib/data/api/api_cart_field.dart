import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/data/repos/cart_field_repo.dart';
import 'package:get/get.dart';

class ApiCartField extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<CartFieldRepo>> getData(String userId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('order_sport_field')
        .where('userID', isEqualTo: userId)
        .get();
    return snapshot.docs
        .map((doc) => CartFieldRepo.fromFirestore(doc))
        .toList();
  }

  Future<List<String>> getBookedTimes(String sportFieldId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('order_sport_field')
        .where('sport_field_id', isEqualTo: sportFieldId)
        .where('isBook', isEqualTo: true)
        .get();

    return snapshot.docs.map((doc) => doc['time'] as String).toList();
  }

  Future<List<Map<String, String>>> getBookedTimesWithDate(
      String sportFieldId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('order_sport_field')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .where('isBook', isEqualTo: true)
          .get();

      List<Map<String, String>> bookedTimesWithDate = [];

      for (var doc in snapshot.docs) {
        String time = doc['time'] as String;
        String date = doc['DatePick'] as String;

        bookedTimesWithDate.add({
          'time': time,
          'date': date,
        });
      }

      return bookedTimesWithDate;
    } catch (e) {
      print("Error getting booked times: $e");
      return [];
    }
  }

  Future<String> getBookedTimesByDocIdAndSportFieldId(
      String docId, String sportFieldId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('order_sport_field')
        .where('sport_field_id', isEqualTo: sportFieldId)
        .get();

    for (var doc in snapshot.docs) {
      if (doc.id == docId) {
        return doc['time'] as String;
      }
    }

    // return "";
    throw Exception(
        'Document not found with the given docId and sport_field_id');
  }

  Future<String?> getStringBookedTimesBySportFieldId(
      String sportFieldId, String DatePick) async {
    QuerySnapshot snapshot = await _firestore
        .collection('order_sport_field')
        .where('sport_field_id', isEqualTo: sportFieldId)
        .where('DatePick', isEqualTo: DatePick)
        .where('isBook', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      return doc['time'] as String?;
    }
    return null;
  }

  Future<void> removeItemCart(String id) async {
    await _firestore.collection('order_sport_field').doc(id).delete();
  }

  Future<void> updateBookingTime(String Id, String time) async {
    await _firestore.collection('order_sport_field').doc(Id).update({
      'time': time,
      'isBook': true,
    });
  }

  Stream<int> getBookingCountStream(String sportFieldId, String userID) {
    return _firestore
        .collection('order_sport_field')
        .where('sport_field_id', isEqualTo: sportFieldId)
        .where("userID", isEqualTo: userID)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  Future<void> addBooking(CartFieldRepo booking) async {
    await _firestore.collection('order_sport_field').add({
      'name': booking.spname,
      'image': booking.image,
      'price': booking.price,
      'sport_field_id': booking.sport_id,
      'time': booking.Time,
      'isBook': booking.isBook,
      'userID': booking.userID,
      'DatePick': booking.DatePick
    });

    var sportFieldRef =
        _firestore.collection('sport_field').doc(booking.sport_id);
    await sportFieldRef.update({
      'isBook': true,
    });
  }

  Future<String?> getUserIDBySportId(String sportFieldId) async {
    QuerySnapshot snapshot = await _firestore
        .collection('order_sport_field')
        .where('sport_field_id', isEqualTo: sportFieldId)
        .where('isBook', isEqualTo: true)
        .get();

    for (var doc in snapshot.docs) {
      return doc['userID'] as String?;
    }
    return null;
  }
}
