import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'users_ctrl.dart';
import '../theme.dart';

class CreateFieldCtrl extends GetxController {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  RxString spname = ''.obs;
  RxString address = ''.obs;
  RxString phoneNumber = ''.obs;
  RxInt price = 0.obs;
  RxString openDay = ''.obs;
  RxString cateID = ''.obs;
  RxString image = ''.obs;
  Rx<Timestamp?> openTime = Rx<Timestamp?>(null);
  Rx<Timestamp?> closeTime = Rx<Timestamp?>(null);
  Rx<File?> _imageFile = Rx<File?>(null);

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
        image.value = pickedFile.path; // Update image path for display
      }
    }
  }

  Future<String?> _uploadImage() async {
    if (_imageFile.value == null) return null;
    try {
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = _storage.ref().child('image').child(fileName);
      await ref.putFile(_imageFile.value!);
      String downloadURL = await ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  Future<void> createSportField() async {
    try {
      if (openTime.value != null &&
          closeTime.value != null &&
          openTime.value!.toDate().isAfter(closeTime.value!.toDate())) {
        Get.snackbar(
          'Error',
          'Open time must be earlier than close time',
          backgroundColor: Colors.red,
          colorText: colorWhite,
        );
        return;
      }

      String? downloadURL = await _uploadImage();
      if (downloadURL == null) {
        Get.snackbar(
          'Error',
          'Failed to upload image',
          backgroundColor: Colors.red,
          colorText: colorWhite,
        );
        return;
      }

      final docRef = FirebaseFirestore.instance.collection('sportfield').doc();
      await docRef.set({
        'name': spname.value,
        'address': address.value,
        'phonenumber': phoneNumber.value,
        'price': price.value,
        'author': Get.find<UsersCtrl>().currentUser.value?.name ?? 'Unknown',
        'authorURL': Get.find<UsersCtrl>().currentUser.value?.id ?? '',
        'openDay': openDay.value,
        'openTime': openTime.value,
        'closeTime': closeTime.value,
        'cateID': cateID.value,
        // 'userID': '',
        'image': downloadURL,
      });
      Get.snackbar(
        'Success',
        'Sport field created successfully',
        backgroundColor: primaryColor500,
        colorText: colorWhite,
      );

      initFields();
      update();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create sport field',
        backgroundColor: Colors.red,
        colorText: colorWhite,
      );
      print('Error creating sport field: $e');
    }
  }

  void initFields() {
    spname.value = '';
    address.value = '';
    phoneNumber.value = '';
    price.value = 0;
    openDay.value = '';
    cateID.value = '';
    image.value = '';
    _imageFile.value = null;
    formattedOpenTime.value = '';
    formattedCloseTime.value = '';
  }

  void updateOpenTime(DateTime openDateTime) {
    if (closeTime.value != null &&
        openDateTime.isAfter(closeTime.value!.toDate())) {
      Get.snackbar(
        'Error',
        'Open time must be earlier than close time',
        backgroundColor: Colors.red,
        colorText: colorWhite,
      );
      return;
    }

    if (closeTime.value != null &&
        openDateTime.isAtSameMomentAs(closeTime.value!.toDate())) {
      Get.snackbar(
        'Error',
        'Open time cannot be the same as close time',
        backgroundColor: Colors.red,
        colorText: colorWhite,
      );
      return;
    }

    openTime.value = Timestamp.fromDate(openDateTime);
    formattedOpenTime.value =
        '${openDateTime.hour}:${openDateTime.minute.toString().padLeft(2, '0')}';
  }

  void updateCloseTime(DateTime closeDateTime) {
    if (openTime.value != null &&
        closeDateTime.isBefore(openTime.value!.toDate())) {
      Get.snackbar(
        'Error',
        'Close time must be later than open time',
        backgroundColor: Colors.red,
        colorText: colorWhite,
      );
      return;
    }

    if (openTime.value != null &&
        closeDateTime.isAtSameMomentAs(openTime.value!.toDate())) {
      Get.snackbar(
        'Error',
        'Close time cannot be the same as open time',
        backgroundColor: Colors.red,
        colorText: colorWhite,
      );
      return;
    }

    closeTime.value = Timestamp.fromDate(closeDateTime);
    formattedCloseTime.value =
        '${closeDateTime.hour}:${closeDateTime.minute.toString().padLeft(2, '0')}';
  }
}
