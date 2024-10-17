import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/show_error_scbar.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  _ChangePasswordViewState createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _changePassword() async {
    String currentPassword = _currentPasswordController.text.trim();
    String newPassword = _newPasswordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (currentPassword.isEmpty) {
      showErrorScBar("Enter current password", title: "Current Password");
    } else if (newPassword.isEmpty) {
      showErrorScBar("Enter new password", title: "New Password");
    } else if (confirmPassword.isEmpty) {
      showErrorScBar("Confirm new password", title: "Confirm Password");
    } else if (newPassword != confirmPassword) {
      showErrorScBar("New passwords do not match", title: "Error");
    } else if (newPassword.length < 8) {
      showErrorScBar("New password must be at least 8 characters",
          title: "Error");
    } else {
      try {
        User? user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          AuthCredential credential = EmailAuthProvider.credential(
            email: user.email!,
            password: currentPassword,
          );

          await user.reauthenticateWithCredential(credential);

          await user.updatePassword(newPassword);
          await user.reload();
          user = FirebaseAuth.instance.currentUser;

          print("Password changed successfully");

          Get.snackbar(
            'Password Changed',
            'Your password has been updated successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );

          _currentPasswordController.clear();
          _newPasswordController.clear();
          _confirmPasswordController.clear();

          Get.back();
        }
      } catch (e) {
        print("Error changing password: $e"); // Debug print
        showErrorScBar("Failed to change password: $e", title: "Error");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Change Password"),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Current Password"),
            ),
            TextField(
              controller: _newPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "New Password"),
            ),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(labelText: "Confirm New Password"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text("Change Password"),
            ),
          ],
        ),
      ),
    );
  }
}
