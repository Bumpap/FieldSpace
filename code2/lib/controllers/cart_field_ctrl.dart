import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../data/api/api_cart_field.dart';
import '../data/api/api_sport_field.dart';
import '../data/repos/cart_field_repo.dart';

class CartFieldCtrl extends GetxController {
  final ApiSportField _apiSportField = Get.find();
  final RxMap<String, String> _addresses = <String, String>{}.obs;
  final RxMap<String, String> _image = <String, String>{}.obs;
  final RxBool _isLoading = false.obs;
  RxInt totalPrice = 0.obs;

  RxList<CartFieldRepo> items = RxList<CartFieldRepo>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    var data = await Get.find<ApiCartField>().getData(user!.uid);
    items.assignAll(data);

    for (var item in items) {
      if (!_addresses.containsKey(item.sport_id)) {
        var address = await _apiSportField.getSportFieldAddress(item.sport_id);
        _addresses[item.sport_id] = address;
      }
    }

    for (var item in items) {
      if (!_image.containsKey(item.sport_id)) {
        var image = await _apiSportField.getSportFieldImage(item.sport_id);
        _image[item.sport_id] = image;
      }
    }
    updateTotalPrice();
    update();
  }

  void updateTotalPrice() {
    totalPrice.value = items.fold(0, (total, item) => total + item.price);
  }

  String getAddress(String sportFieldId) {
    return _addresses[sportFieldId] ?? 'Address not found';
  }

  String getImage(String sportFieldId) {
    return _image[sportFieldId] ?? 'Image not found';
  }

  void addBooking(CartFieldRepo booking) async {
    await Get.find<ApiCartField>().addBooking(booking);
    fetchData();
  }

  void updateBookingTime(String id, String time) async {
    await Get.find<ApiCartField>().updateBookingTime(id, time);
    fetchData();
  }

  Future<List<String>> getBookedTimes(String id) async {
    return await Get.find<ApiCartField>().getBookedTimes(id);
  }

  Future<List<Map<String, String>>> getBookedTimesWithDate(
      String sportFieldId) async {
    return await Get.find<ApiCartField>().getBookedTimesWithDate(sportFieldId);
  }

  Future<String> getBookedTimesByDocIdAndSportFieldId(
      String id, String SportfieldId) async {
    return await Get.find<ApiCartField>()
        .getBookedTimesByDocIdAndSportFieldId(id, SportfieldId);
  }

  Future<String?> getStringBookedTimesBySportFieldId(
      String SportfieldId, String DatePick) async {
    return await Get.find<ApiCartField>()
        .getStringBookedTimesBySportFieldId(SportfieldId, DatePick);
  }

  int getTotalPrice() {
    return totalPrice.value;
  }

  Future<void> checkout(String userID) async {
    if (items.isEmpty) {
      Get.snackbar(
        'Checkout Error',
        'There are no items in your cart to checkout.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _isLoading.value = true;

    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('checkout_history_order').add({
        'items': items.map((item) => item.toJson()).toList(),
        'totalPrice': getTotalPrice(),
        'timestamp': FieldValue.serverTimestamp(),
        'userID': userID
      });

      for (var item in items) {
        await firestore.collection('order_sport_field').doc(item.id).delete();
      }

      items.clear();
    } catch (e) {
      Get.snackbar(
        'Checkout Error',
        'An error occurred while processing the checkout.',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading.value = false;
      update();
    }
  }

  bool get isLoading => _isLoading.value;

  bool isCurrentlyBooked(String sportFieldId) {
    DateTime now = DateTime.now();
    for (var item in items) {
      if (item.sport_id == sportFieldId && item.isBook) {
        List<String> timeRange = item.Time.replaceAll('.', ':').split(' - ');
        DateTime start = DateFormat("HH:mm").parse(timeRange[0]);
        DateTime end = DateFormat("HH:mm").parse(timeRange[1]);

        DateTime startTime =
            DateTime(now.year, now.month, now.day, start.hour, start.minute);
        DateTime endTime =
            DateTime(now.year, now.month, now.day, end.hour, end.minute);

        if (now.isAfter(startTime) && now.isBefore(endTime)) {
          return true;
        }
      }
    }
    return false;
  }

  String getBookingStatus(String sportFieldId) {
    if (isCurrentlyBooked(sportFieldId)) {
      return "Booked";
    }
    return "NBooked";
  }

  Future<void> removeItemCart(String id) async {
    await Get.find<ApiCartField>().removeItemCart(id);
    items.removeWhere((item) => item.id == id);
    fetchData();
  }

  Future<String?> getUserIDBySportId(String sportFieldId) async {
    fetchData();
    return await Get.find<ApiCartField>().getUserIDBySportId(sportFieldId);
  }
}
