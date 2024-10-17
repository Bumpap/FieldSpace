import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/controllers/location_ctrl.dart';
import 'package:code2/controllers/users_ctrl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/get_rx.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../data/api/api_sport_field.dart';
import '../data/repos/sport_field_repo.dart';
import '../models/radiobox_state.dart';
import '../theme.dart';

class SportFieldCtrl extends GetxController {
  final ApiSportField _api = Get.find();
  final LocationCtrl locationCtrl = Get.find();
  var availableBookTime = <RadioBoxState>[].obs;
  RxSet<String> selectedFields = RxSet<String>();
  final RxMap<String, String> _addresses = <String, String>{}.obs;

  RxList<SportFieldRepo> items = RxList<SportFieldRepo>();
  RxList<SportFieldRepo> selectedListByCategory = RxList<SportFieldRepo>();
  RxInt _quality = 1.obs;

  int get quality => _quality.value;
  final ImagePicker _picker = ImagePicker();
  Rx<File?> _imageFile = Rx<File?>(null);

  RxString selectedTime = ''.obs;
  RxString selectedDate = ''.obs;

  RxString spname = ''.obs;
  RxString address = ''.obs;
  RxString phoneNumber = ''.obs;
  RxInt price = 0.obs;
  RxString openDay = ''.obs;
  RxString cateID = ''.obs;
  RxString image = ''.obs;
  Rx<Timestamp> openTime = Timestamp.now().obs;
  Rx<Timestamp> closeTime = Timestamp.now().obs;

  RxString formattedOpenTime = ''.obs;
  RxString formattedCloseTime = ''.obs;

  List<String> openDayOptions = [
    'All Day',
    'Monday to Friday',
    'Monday to Thursday',
    'Monday to Wednesday',
    'Monday to Tuesday',
    'Monday to Saturday',
    'Tuesday to Saturday',
    'Tuesday to Sunday',
    'Tuesday to Friday',
    'Tuesday to Thursday',
    'Tuesday to Wednesday',
    'Wednesday to Sunday',
    'Wednesday to Saturday',
    'Wednesday to Friday',
    'Wednesday to Thursday',
    'Thursday to Sunday',
    'Thursday to Saturday',
    'Thursday to Friday',
    'Friday to Sunday',
    'Friday to Saturday',
    'Saturday and Sunday',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  Future<void> fetchData() async {
    var data = await _api.getData();
    if (data.isNotEmpty) {
      items.clear();
      items.assignAll(data);

      for (var item in items) {
        if (!_addresses.containsKey(item.id)) {
          var address = await _api.getSportFieldAddress(item.id);
          _addresses[item.id] = address;
        }
        if (!_addresses.containsKey(item.id)) {
          var address = await _api.getSportFieldAddress(item.id);
          _addresses[item.id] = address;
        }
      }
    } else {
      print('No data found');
    }
  }

  Future<void> fetchFieldById(String id) async {
    var field = await _api.getFieldById(id);
    if (field != null) {
      spname.value = field.spname;
      address.value = field.address;
      price.value = field.price;
      phoneNumber.value = field.phoneNumber;
      openDay.value = field.openDay;
      image.value = field.image;
      openTime.value = field.openTime;
      closeTime.value = field.closeTime;
      cateID.value = field.categories;

      formattedOpenTime.value =
          '${field.openTime.toDate().hour}:${field.openTime.toDate().minute.toString().padLeft(2, '0')}';
      formattedCloseTime.value =
          '${field.closeTime.toDate().hour}:${field.closeTime.toDate().minute.toString().padLeft(2, '0')}';
    } else {
      print('Field not found');
    }
  }

  void fetchDataByCategory(String cateid) async {
    var data = await _api.getDataByCategory(cateid);
    if (data.isNotEmpty) {
      selectedListByCategory.clear();
      selectedListByCategory.assignAll(data);
    } else {
      selectedListByCategory.clear();
      print('No data found for category $cateid');
    }
  }

  Future<void> fetchAndUpdateTimes(String fieldId) async {
    var field = await _api.getFieldById(fieldId);
    if (field != null) {
      openTime.value = field.openTime;
      closeTime.value = field.closeTime;

      formattedOpenTime.value =
          '${field.openTime.toDate().hour}:${field.openTime.toDate().minute.toString().padLeft(2, '0')}';
      formattedCloseTime.value =
          '${field.closeTime.toDate().hour}:${field.closeTime.toDate().minute.toString().padLeft(2, '0')}';
    }
  }

  void initSport() {
    _quality.value = 1;
    selectedTime.value = '';
    selectedDate.value = '';
  }

  void setQuantity(bool isIncre) {
    if (isIncre) {
      _quality.value = checkQuality(_quality.value + 1);
    } else {
      _quality.value = checkQuality(_quality.value - 1);
    }
    update();
  }

  int checkQuality(int quality) {
    if (quality < 1) {
      Get.snackbar(
        "Time range",
        "You don't reduce more",
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
      return 1;
    } else if (quality > 4) {
      Get.snackbar(
        "Time range",
        "You don't increase more",
        backgroundColor: Colors.white,
        colorText: Colors.redAccent,
      );
      return 4;
    } else {
      return quality;
    }
  }

  SportFieldRepo? getFieldByIdFromItems(String id) {
    try {
      return items.firstWhere((field) => field.id == id);
    } catch (e) {
      print('Field not found in items: $e');
      return null;
    }
  }

  void toggleSelection(String fieldId) {
    if (selectedFields.contains(fieldId)) {
      selectedFields.remove(fieldId);
    } else {
      selectedFields.add(fieldId);
    }
    update();
  }

  void deleteSelectedFields() async {
    try {
      for (var fieldId in selectedFields) {
        var field = items.firstWhere((field) => field.id == fieldId);

        await FirebaseStorage.instance.refFromURL(field.image).delete();

        await _api.deleteData(fieldId);
      }

      selectedFields.clear();

      items.removeWhere((field) => selectedFields.contains(field.id));

      Get.snackbar(
        "Success",
        "Fields deleted",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      update();
    } catch (e) {
      Get.snackbar(
        "Error",
        "Failed to delete fields",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      print('Error deleting sport fields: $e');
    }
  }

  Future<bool> updateFieldData(String fieldId) async {
    SportFieldRepo updatedField = SportFieldRepo(
      id: fieldId,
      spname: spname.value,
      address: address.value,
      phoneNumber: phoneNumber.value,
      price: price.value,
      author: Get.find<UsersCtrl>().currentUser.value?.name ?? 'Unknown',
      authorURL: Get.find<UsersCtrl>().currentUser.value?.id ?? '',
      openDay: openDay.value,
      openTime: openTime.value,
      closeTime: closeTime.value,
      categories: cateID.value,
      // userID: '',
      image: image.value,
    );
    return await _api.updateField(updatedField);
  }

  void updateOpenTime(DateTime openDateTime) {
    openTime.value = Timestamp.fromDate(openDateTime);
    formattedOpenTime.value =
        '${openDateTime.hour}:${openDateTime.minute.toString().padLeft(2, '0')}';
  }

  void updateCloseTime(DateTime closeDateTime) {
    closeTime.value = Timestamp.fromDate(closeDateTime);
    formattedCloseTime.value =
        '${closeDateTime.hour}:${closeDateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> pickImage(BuildContext context) async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text('Camera'),
                onTap: () {
                  Navigator.pop(context, ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Photo Library'),
                onTap: () {
                  Navigator.pop(context, ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );

    if (source != null) {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _imageFile.value = File(pickedFile.path);
        image.value = pickedFile.path;
      }
    }
  }

  String getAddress(String sportFieldId) {
    return _addresses[sportFieldId] ?? 'Address not found';
  }

  Future<LatLng> getendLocation(String sportFieldId) async {
    return await locationCtrl
        .getCoordinatesFromAddress(getAddress(sportFieldId));
  }
}
