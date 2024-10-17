import 'package:code2/data/api/api_users.dart';
import 'package:code2/data/repos/users_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UsersCtrl extends GetxController {
  final ApiUsers _api = Get.find();
  Rx<UsersRepo?> currentUser = Rx<UsersRepo?>(null);
  RxString imageName = RxString("");
  RxBool isFetching = RxBool(false);
  RxList<UsersRepo> users = RxList<UsersRepo>();
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void onInit() {
    super.onInit();
    fetchCurrentUser();
  }

  void fetchCurrentUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var data = await _api.getUserById(user.uid);
      if (data != null) {
        currentUser.value = data;
        String? imageUrl = data.imagePro;
        if (imageUrl != null) {
          final uri = Uri.parse(imageUrl);
          final pathSegments = uri.pathSegments;
          if (pathSegments.isNotEmpty) {
            imageName.value = pathSegments.last;
          } else {
            imageName.value = "";
          }
        } else {
          imageName.value = "";
        }
      } else {
        currentUser.value = null;
        imageName.value = "";
      }
    } else {
      currentUser.value = null;
      imageName.value = "";
    }
    update();
  }

  void fetchAllUsers() async {
    isFetching.value = true;

    try {
      var allUsers = await _api.getAllUsers();
      if (allUsers.isNotEmpty) {
        users.assignAll(allUsers);
      } else {
        print("No users found.");
      }
    } catch (e) {
      print("Error fetching users in controller: $e");
    } finally {
      isFetching.value = false;
      update();
    }
  }

  List<Map<String, String>> getSuggestions(String query) {
    if (query.isEmpty) {
      return [];
    }
    return users
        .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
        .map((item) => {
              'email': item.email,
              'name': item.name,
              'id': item.id,
            })
        .toList();
  }

  void updateUserName(String newName) async {
    await Get.find<ApiUsers>().updateUserName(newName, currentUser);
    fetchCurrentUser();
  }

  void updateUserNameById(String newName, String userID) async {
    await Get.find<ApiUsers>().updateUserNameById(newName, userID);
    fetchCurrentUser();
  }

  void updateUserPhone(String newPhone) async {
    await Get.find<ApiUsers>().updateUserPhone(newPhone, currentUser);
    fetchCurrentUser();
  }

  void updateUserPhoneById(String newPhone, String userID) async {
    await Get.find<ApiUsers>().updateUserPhoneById(newPhone, userID);
    fetchCurrentUser();
  }

  void updateUserPasswordById(String newPass, String userID) async {
    await Get.find<ApiUsers>().updateUserPasswordById(newPass, userID);
    fetchCurrentUser();
  }

  void updateUserEmailById(String newEmail, String userID) async {
    await Get.find<ApiUsers>().updateUserEmailById(newEmail, userID);
    fetchCurrentUser();
  }

  void addAccount(UsersRepo newuser) async {
    await Get.find<ApiUsers>().addAccount(newuser);
    fetchCurrentUser();
  }

  void logout() async {
    await FirebaseAuth.instance.signOut();
    await _googleSignIn.signOut();
    await FacebookAuth.instance.logOut();
    currentUser.value = null;
    imageName.value = "";
    update();
  }

  Future<String?> uploadProfileImage({required ImageSource source}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String fileName = '${DateTime.now().millisecondsSinceEpoch}.png';
      var user = currentUser.value;

      try {
        if (user?.imagePro != null && user!.imagePro.isNotEmpty) {
          try {
            // Extract the file name from the URL
            String oldFileName = imageName.value;
            FirebaseStorage.instance.ref().child('$oldFileName').delete();
          } catch (e) {
            print("Error deleting old image: $e");
          }
        }

        UploadTask uploadTask = FirebaseStorage.instance
            .ref()
            .child('image/$fileName')
            .putFile(file);
        TaskSnapshot taskSnapshot = await uploadTask;
        String downloadURL = await taskSnapshot.ref.getDownloadURL();

        await _api.updateUserImage(currentUser.value!.id, downloadURL);

        fetchCurrentUser();

        return downloadURL;
      } catch (e) {
        print("Error uploading image: $e");
        return null;
      }
    }
    return null;
  }

  void updateProfileImageName(String name) {
    imageName.value = name;
  }

  void deleteUser(String userId) async {
    await _api.deleteUser(userId);
    fetchAllUsers();
  }

  void deleteAuthorUserAndUserCollection(String userId) async {
    await _api.deleteAuthorUserAndUserCollection(userId);
    fetchAllUsers();
  }

  Future<void> getSignInMethod(String userId) async {
    try {
      String signInMethod = await _api.getSignInMethod(userId);
      print("Sign-in method for user $userId: $signInMethod");
    } catch (e) {
      print("Error getting sign-in method: $e");
    }
  }
}
