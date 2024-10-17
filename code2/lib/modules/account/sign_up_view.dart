import 'package:code2/components/app_text_field.dart';
import 'package:code2/components/show_error_scbar.dart';
import 'package:code2/data/repos/users_repo.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/big_text7.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../data/api/api_users.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  _SignUpViewState createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  var emailCtrl = TextEditingController();
  var passCtrl = TextEditingController();
  var nameCtrl = TextEditingController();
  var phoneCtrl = TextEditingController();
  bool obscureText = true;
  String _selectedRole = 'user';

  void _togglePasswordVisibility() {
    setState(() {
      obscureText = !obscureText;
    });
  }

  void _regisCtrl() async {
    String name = nameCtrl.text.trim();
    String pass = passCtrl.text.trim();
    String nbphone = phoneCtrl.text.trim();
    String email = emailCtrl.text.trim();

    if (email.isEmpty) {
      showErrorScBar("Input your email", title: "Email");
    } else if (!GetUtils.isEmail(email)) {
      showErrorScBar("Not email format", title: "Email");
    } else if (pass.isEmpty) {
      showErrorScBar("Input your password", title: "Pass");
    } else if (pass.length < 8) {
      showErrorScBar("Your password can not be less than 8 characters",
          title: "Pass");
    } else if (name.isEmpty) {
      showErrorScBar("Input your name", title: "Name");
    } else if (nbphone.isEmpty) {
      showErrorScBar("Input your phone", title: "Phone");
    } else if (!GetUtils.isPhoneNumber(nbphone)) {
      showErrorScBar("Not phone number format", title: "Phone");
    } else {
      try {
        bool emailExists = await Get.find<ApiUsers>().checkEmailExists(email);
        bool passwordExists =
            await Get.find<ApiUsers>().checkPasswordExists(pass);
        FirebaseAuth auth = FirebaseAuth.instance;

        if (emailExists) {
          showErrorScBar("Email already exists", title: "Email");
        } else if (passwordExists) {
          showErrorScBar("Password already exists", title: "Password");
        } else {
          UserCredential userCredential =
              await auth.createUserWithEmailAndPassword(
            email: email,
            password: pass,
          );

          UsersRepo newUser = UsersRepo(
              id: userCredential.user!.uid,
              email: email,
              password: pass,
              name: name,
              phoneNb: nbphone,
              imagePro: '',
              role: _selectedRole);

          await Get.find<ApiUsers>().addAccount(newUser);

          nameCtrl.clear();
          passCtrl.clear();
          phoneCtrl.clear();
          emailCtrl.clear();

          Get.snackbar(
            'Sign up successfully',
            'Your account has been created',
            snackPosition: SnackPosition.TOP,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        showErrorScBar("Failed to create account", title: "Error");
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
            // Email
            AppTextField(
              txtCtrl: emailCtrl,
              hintTxt: "Email",
              iconData: Icons.email,
            ),
            SizedBox(height: Demensions.height20),
            // Pass
            AppTextField(
              txtCtrl: passCtrl,
              hintTxt: "Password",
              iconData: Icons.lock,
              isObs: true,
              obscureText: obscureText,
              suffixIconOnTap: _togglePasswordVisibility,
            ),
            SizedBox(height: Demensions.height20),
            // Name
            AppTextField(
              txtCtrl: nameCtrl,
              hintTxt: "Name",
              iconData: Icons.person,
            ),
            SizedBox(height: Demensions.height20),
            // Phone
            AppTextField(
              txtCtrl: phoneCtrl,
              hintTxt: "Phone",
              iconData: Icons.phone,
            ),
            SizedBox(height: Demensions.height20),
            // Radio Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Radio<String>(
                      value: 'user',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    Text('User'),
                  ],
                ),
                Row(
                  children: [
                    Radio<String>(
                      value: 'coach',
                      groupValue: _selectedRole,
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value!;
                        });
                      },
                    ),
                    Text('Coach'),
                  ],
                ),
              ],
            ),
            SizedBox(height: Demensions.height20),
            GestureDetector(
              onTap: () {
                _regisCtrl();
              },
              child: Container(
                width: Demensions.screenWidth / 2,
                height: Demensions.screenHeight / 13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Demensions.radius30),
                  color: primaryColor500,
                ),
                child: Center(
                  child: BigText7(text: "Sign Up"),
                ),
              ),
            ),
            SizedBox(height: Demensions.height10),
            RichText(
              text: TextSpan(
                recognizer: TapGestureRecognizer()..onTap = () => Get.back(),
                text: "Have an account already?",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: Demensions.font20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
