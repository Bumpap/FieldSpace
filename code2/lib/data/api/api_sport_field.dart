import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../repos/sport_field_repo.dart';

class ApiSportField extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<SportFieldRepo>> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('sportfield').get();
      return snapshot.docs
          .map((doc) => SportFieldRepo.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<List<SportFieldRepo>> getDataByCategory(String cateid) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('sportfield')
          .where('cateID', isEqualTo: cateid)
          .get();
      return snapshot.docs
          .map((doc) => SportFieldRepo.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error fetching data by category: $e');
      return [];
    }
  }

  Future<SportFieldRepo?> getFieldById(String id) async {
    try {
      DocumentSnapshot snapshot =
          await _firestore.collection('sportfield').doc(id).get();
      if (snapshot.exists) {
        return SportFieldRepo.fromFirestore(snapshot);
      }
      return null;
    } catch (e) {
      print('Error fetching field by ID: $e');
      return null;
    }
  }

  Future<String> getSportFieldAddress(String sportFieldId) async {
    DocumentSnapshot doc =
        await _firestore.collection('sportfield').doc(sportFieldId).get();
    return doc['address'] ?? 'Address not found';
  }

  Future<String> getSportFieldImage(String sportFieldId) async {
    DocumentSnapshot doc =
        await _firestore.collection('sportfield').doc(sportFieldId).get();
    return doc['image'] ?? 'image not found';
  }

  Future<void> deleteData(String fieldId) async {
    try {
      CollectionReference sportFields = _firestore.collection('sportfield');

      await sportFields.doc(fieldId).delete();

      print('Sport field deleted successfully.');
    } catch (e) {
      print('Error deleting sport field: $e');
    }
  }

  Future<bool> updateField(SportFieldRepo field) async {
    try {
      await _firestore
          .collection('sportfield')
          .doc(field.id)
          .update(field.toMap());
      return true;
    } catch (e) {
      print("Error updating document: $e");
      return false;
    }
  }
}
