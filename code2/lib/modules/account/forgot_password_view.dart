import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/app_text_field.dart';
import '../../components/show_error_scbar.dart';
import '../../models/demensions.dart';
import '../../theme.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  _ForgotPasswordViewState createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final TextEditingController _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  void _resetPassword() async {
    String email = _emailCtrl.text.trim();

    if (email.isEmpty) {
      showErrorScBar("Input your email", title: "Email");
    } else if (!GetUtils.isEmail(email)) {
      showErrorScBar("Not email format", title: "Email");
    } else {
      try {
        await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
        await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

        Get.snackbar(
          'Password Reset Email Sent',
          'Check your email to reset your password.',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        _emailCtrl.clear();
      } catch (e) {
        if (e is FirebaseAuthException) {
          if (e.code == 'user-not-found') {
            showErrorScBar("No account found with this email", title: "Error");
          } else {
            showErrorScBar("Failed to send reset email: ${e.message}",
                title: "Error");
          }
        } else {
          showErrorScBar("Failed to send reset email", title: "Error");
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: Demensions.screenHeight * 0.05),
            Container(
              height: Demensions.screenHeight * 0.25,
              child: Center(
                child: ClipOval(
                  child: Image.asset(
                    "assets/images/logo.png",
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: Demensions.width20),
              child: Column(
                children: [
                  Text(
                    "Reset Password",
                    style: TextStyle(
                      fontSize: Demensions.font20 * 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            // Email
            AppTextField(
              txtCtrl: _emailCtrl,
              hintTxt: "Email",
              iconData: Icons.email,
            ),
            SizedBox(height: Demensions.height20),
            GestureDetector(
              onTap: _resetPassword,
              child: Container(
                width: Demensions.screenWidth / 2,
                height: Demensions.screenHeight / 13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Demensions.radius30),
                  color: primaryColor500,
                ),
                child: Center(
                  child: Text(
                    "Send Reset Email",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: Demensions.font20,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: Demensions.screenHeight * 0.05),
            RichText(
              text: TextSpan(
                text: "Remembered your password? ",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: Demensions.font16,
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.back(),
                    text: "Sign In",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor300,
                      fontSize: Demensions.font16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
