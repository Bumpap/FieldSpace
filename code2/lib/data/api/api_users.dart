import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/show_error_scbar.dart';
import '../repos/users_repo.dart';

class ApiUsers extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<UsersRepo>> getData() async {
    QuerySnapshot snapshot = await _firestore.collection('users').get();
    return snapshot.docs.map((doc) => UsersRepo.fromFirestore(doc)).toList();
  }

  Future<void> addAccount(UsersRepo account) async {
    await _firestore.collection('users').doc(account.id).set({
      'email': account.email,
      'password': account.password,
      'name': account.name,
      'phonenumber': account.phoneNb,
      'image': account.imagePro,
      'role': account.role
    });
  }

  Future<bool> checkEmailExists(String email) async {
    var result = await _firestore.collection('users').where('email', isEqualTo: email).get();
    return result.docs.isNotEmpty;
  }

  Future<bool> checkPasswordExists(String password) async {
    var result = await _firestore.collection('users').where('password', isEqualTo: password).get();
    return result.docs.isNotEmpty;
  }

  Future<UsersRepo?> getUserById(String id) async {
    var doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return UsersRepo.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateUserImage(String userId, String imageUrl) async {
    await _firestore.collection('users').doc(userId).update({
      'image': imageUrl,
    });
  }

  Future<void> updateUserName(String newName, Rx<UsersRepo?> currentUser) async {
    if (currentUser.value != null) {
      try {
        await _firestore
            .collection('users')
            .doc(currentUser.value!.id)
            .update({'name': newName});
      } catch (e) {
        print("Failed to update user name: $e");
      }
    }
  }

  Future<void> updateUserNameById(String newName, String userID) async {
      try {
        await _firestore
            .collection('users')
            .doc(userID)
            .update({'name': newName});
      } catch (e) {
        print("Failed to update user name: $e");
      }
  }

  Future<void> updateUserPhone(String newPhone, Rx<UsersRepo?> currentUser) async {

    if (!GetUtils.isPhoneNumber(newPhone)) {
      Get.snackbar("Error", "Please enter a valid number.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    if (currentUser.value != null) {
      try {
        await _firestore
            .collection('users')
            .doc(currentUser.value!.id)
            .update({'phonenumber': newPhone});
      } catch (e) {
        print("Failed to update user phone: $e");
      }
    }
  }

  Future<void> updateUserPhoneById(String newPhone, String userID) async {

    if (!GetUtils.isPhoneNumber(newPhone)) {
      Get.snackbar("Error", "Please enter a valid number.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {
      await _firestore
          .collection('users')
          .doc(userID)
          .update({'phonenumber': newPhone});
    } catch (e) {
      print("Failed to update user phone: $e");
    }
  }

  Future<void> updateUserEmailById(String newEmail, String userID) async{
    if (!GetUtils.isEmail(newEmail)) {
      Get.snackbar("Error", "Please enter a valid email.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }
    try {

      String? email = await getEmailById(userID);
      String? password = await getPasswordById(userID);

      UserCredential? userCredential;

      if (email == null || password == null || email == "" || password == "") {
        String signInMethod = await getSignInMethod(userID);
        if (signInMethod == 'google.com') {
          showErrorScBar("Your account you want to change is login with google", title: "Email");
          return;
        }
        else if(signInMethod == 'facebook.com'){
          showErrorScBar("Your account you want to change is login with facebook", title: "Email");
          return;
        }
      } else{
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      User? user = userCredential?.user;
      if (user != null && user.uid == userID) {
        await user.verifyBeforeUpdateEmail(newEmail);
        await user.reload();
        await _firestore
            .collection('users')
            .doc(userID)
            .update({'email': newEmail});
      }
    } catch (e) {
      print("Failed to update user email: $e");
    }
  }

  Future<List<UsersRepo>> getAllUsers() async {
    try {
      print("Start fetching users...");
      QuerySnapshot snapshot = await _firestore.collection('users').get();
      print("Fetched ${snapshot.docs.length} users from Firestore.");

      return snapshot.docs.map((doc) => UsersRepo.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching users: $e");
      return [];
    }
  }

  Future<void> deleteUser(String userId) async {
    await _firestore.collection('users').doc(userId).delete();
  }

  Future<String?> getPasswordById(String id) async {
    var doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return doc.get('password');
    }
    return null;
  }

  Future<String?> getEmailById(String id) async {
    var doc = await _firestore.collection('users').doc(id).get();
    if (doc.exists) {
      return doc.get('email');
    }
    return null;
  }

  Future<String?> getAccessTokenById(String id) async {
    var doc = await _firestore.collection('delete_account_google_facebook').doc(id).get();
    if (doc.exists) {
      return doc.get('accessToken');
    }
    return null;
  }

  Future<String?> getIdTokenById(String id) async {
    var doc = await _firestore.collection('delete_account_google_facebook').doc(id).get();
    if (doc.exists) {
      return doc.get('idToken');
    }
    return null;
  }

  Future<void> deleteAuthorUserAndUserCollection(String userId) async {
    try {
      String? email = await getEmailById(userId);
      String? password = await getPasswordById(userId);

      UserCredential? userCredential;

      if (email == null || password == null || email == "" || password == "") {
        String signInMethod = await getSignInMethod(userId);
        if (signInMethod == 'google.com') {
          String? accessToken = await getAccessTokenById(userId);
          String? idToken = await getIdTokenById(userId);
          final OAuthCredential credential = GoogleAuthProvider.credential(
            accessToken: accessToken,
            idToken: idToken,
          );
          userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          await userCredential.user?.unlink('google.com');
          await FirebaseFirestore.instance
              .collection('delete_account_google_facebook')
              .doc(userId)
              .delete();
        }
        else if (signInMethod == 'facebook.com') {
          String? accessToken = await getAccessTokenById(userId);
          final OAuthCredential credential = FacebookAuthProvider.credential(accessToken!);
          userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
          await userCredential.user?.unlink('facebook.com');
          await FirebaseFirestore.instance
              .collection('delete_account_google_facebook')
              .doc(userId)
              .delete();
        }
      } else {
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      User? user = userCredential?.user;
      if (user != null) {
        await user.delete();
        await deleteUser(userId);
        print("User deleted successfully.");
      } else {
        print("No user found for the provided credentials.");
      }
    } catch (e) {
      print("Error occurred: ${e.toString()}");
    }
  }

  Future<void> updateUserPasswordById(String newPassword, String userID) async {
    try {

      String? email = await getEmailById(userID);
      String? password = await getPasswordById(userID);

      UserCredential? userCredential;

      if (email == null || password == null || email == "" || password == "") {
        // Check if the user signed in with Google
        String signInMethod = await getSignInMethod(userID);
        if (signInMethod == 'google.com') {
          showErrorScBar("Your account you want to change is login with google", title: "Pass");
          return;
        }
        else if(signInMethod == 'facebook.com'){
          showErrorScBar("Your account you want to change is login with facebook", title: "Pass");
          return;
        }
      } else{
        userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      User? user = userCredential?.user;
      if (user != null && user.uid == userID) {
        if (newPassword.length < 8){
          showErrorScBar("Your password want to change can not be less than 8 characters", title: "Pass");
        }else{
          await user.updatePassword(newPassword);
          await user.reload();
          await _firestore
              .collection('users')
              .doc(userID)
              .update({'password': newPassword});
          print("Password updated successfully.");
        }
      } else {
        print("User not authenticated or ID mismatch.");
      }
    } on FirebaseAuthException catch (e) {
      print("Failed to update password: ${e.message}");
    } catch (e) {
      print("Error occurred: ${e.toString()}");
    }
  }

  Future<String> getSignInMethod(String uid) async {
    // Retrieve the sign-in method from Firestore
    DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('delete_account_google_facebook')
        .doc(uid)
        .get();

    if (snapshot.exists) {
      // Extract the sign-in method
      String signInMethod = snapshot.get('signInMethod');
      return signInMethod;
    } else {
      return 'Unknown';
    }
  }
}
