import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/components/app_text_field.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/modules/account/sign_up_view.dart';
import 'package:code2/route/route_view.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/big_text7.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../components/show_error_scbar.dart';
import '../../controllers/users_ctrl.dart';
import '../../data/api/api_users.dart';
import '../../data/repos/users_repo.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  _SignInViewState createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();
  bool _obscureText = true;
  String _selectedRole = 'user';

  var signUpImg = [
    "face.png",
    "google.png",
  ];

  @override
  void dispose() {
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  void _loginCtrl() async {
    String email = emailCtrl.text.trim();
    String pass = passCtrl.text.trim();

    if (email.isEmpty) {
      showErrorScBar("Input your email", title: "Email");
    } else if (!GetUtils.isEmail(email)) {
      showErrorScBar("Not email format", title: "Email");
    } else if (pass.isEmpty) {
      showErrorScBar("Input your password", title: "Pass");
    } else if (pass.length < 8) {
      showErrorScBar("Your password can not be less than 8 characters",
          title: "Pass");
    } else {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: pass,
        );

        _handleUserLogin(userCredential);
      } catch (e) {
        showErrorScBar("Failed to login", title: "Error");
      }
    }
  }

  void _handleUserLogin(UserCredential userCredential) async {
    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(userCredential.user?.uid)
        .get();

    String role = userDoc['role'];
    if (role == 'admin') {
      Get.find<UsersCtrl>().fetchCurrentUser();
      Get.snackbar(
        'Login successful',
        'Welcome back!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      emailCtrl.clear();
      passCtrl.clear();

      Get.offNamed(RouteView.getAdminPage());
      Get.toNamed(RouteView.getAdminPage());
    } else if (role == 'user' || role == 'coach') {
      Get.find<UsersCtrl>().fetchCurrentUser();
      Get.snackbar(
        'Login successful',
        'Welcome back!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );

      emailCtrl.clear();
      passCtrl.clear();

      Get.offNamed(RouteView.getHome());
      Get.toNamed(RouteView.getHome());
    }
  }

  Future<void> _signInOrSignUpWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        showErrorScBar("Google sign-in was canceled",
            title: "Sign-In Canceled");
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        String email = user.email!;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        await FirebaseFirestore.instance
            .collection('delete_account_google_facebook')
            .doc(user.uid)
            .set({
          'accessToken': googleAuth.accessToken,
          'idToken': googleAuth.idToken,
          'signInMethod': credential.signInMethod
        });

        if (!userDoc.exists) {
          bool emailExists = await Get.find<ApiUsers>().checkEmailExists(email);

          if (emailExists) {
            showErrorScBar("Email already exists", title: "Email");
            await FirebaseAuth.instance.signOut();
            return;
          } else {
            UsersRepo newUser = UsersRepo(
              id: user.uid,
              email: email,
              password: '',
              role: _selectedRole,
              name: user.displayName ?? '',
              phoneNb: user.phoneNumber ?? '',
              imagePro: user.photoURL ?? '',
            );

            await Get.find<ApiUsers>().addAccount(newUser);

            Get.snackbar(
              'Sign up successfully',
              'Your account has been created with Google',
              snackPosition: SnackPosition.TOP,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          }
        } else {
          _handleUserLogin(userCredential);
        }
      }
    } catch (e) {
      print("Error: $e");
      showErrorScBar("Failed to sign in or sign up with Google",
          title: "Error");
    }
  }

  Future<void> _signInOrSignUpWithFacebook() async {
    try {
      final LoginResult result = await FacebookAuth.instance.login();

      if (result.status == LoginStatus.success) {
        final AccessToken accessToken = result.accessToken!;
        final OAuthCredential credential =
            FacebookAuthProvider.credential(accessToken.tokenString);

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);
        User? user = userCredential.user;

        if (user != null) {
          String email = user.email!;

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .get();

          await FirebaseFirestore.instance
              .collection('delete_account_google_facebook')
              .doc(user.uid)
              .set({
            'accessToken': accessToken.tokenString,
            'idToken': null,
            'signInMethod': credential.signInMethod
          });

          if (userDoc.exists) {
            _handleUserLogin(userCredential);
          } else {
            bool emailExists =
                await Get.find<ApiUsers>().checkEmailExists(email);

            if (emailExists) {
              showErrorScBar("Email already exists", title: "Email");
              await FirebaseAuth.instance.signOut();
            } else {
              UsersRepo newUser = UsersRepo(
                id: user.uid,
                email: email,
                password: '',
                role: _selectedRole,
                name: user.displayName ?? '',
                phoneNb: user.phoneNumber ?? '',
                imagePro: user.photoURL ?? '',
              );

              await Get.find<ApiUsers>().addAccount(newUser);

              Get.snackbar(
                'Sign up successfully',
                'Your account has been created with Facebook',
                snackPosition: SnackPosition.TOP,
                backgroundColor: Colors.green,
                colorText: Colors.white,
              );

              _handleUserLogin(userCredential);
            }
          }
        }
      } else if (result.status == LoginStatus.cancelled) {
        showErrorScBar("Facebook sign-in was canceled",
            title: "Sign-In Canceled");
      } else {
        showErrorScBar("Failed to sign in with Facebook", title: "Error");
      }
    } catch (e) {
      print("Error: $e");
      showErrorScBar("Failed to sign in with Facebook", title: "Error");
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _obscureText = !_obscureText;
    });
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
            //Say welcome
            Container(
              margin: EdgeInsets.only(left: Demensions.width20),
              child: Column(
                children: [
                  Text(
                    "FieldSpace",
                    style: TextStyle(
                      fontSize: Demensions.font20 * 3 + Demensions.font20 / 2,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
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
              obscureText: _obscureText,
              suffixIconOnTap: _togglePasswordVisibility,
            ),
            SizedBox(height: Demensions.height20),
            Row(
              children: [
                Expanded(child: Container()),
                RichText(
                  text: TextSpan(
                    text: "Forgot password?",
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontSize: Demensions.font16,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.toNamed(RouteView.getForGotView()),
                  ),
                ),
                SizedBox(width: Demensions.width20),
              ],
            ),
            SizedBox(height: Demensions.height20),
            GestureDetector(
              onTap: _loginCtrl,
              child: Container(
                width: Demensions.screenWidth / 2,
                height: Demensions.screenHeight / 13,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Demensions.radius30),
                  color: primaryColor500,
                ),
                child: Center(
                  child: BigText7(text: "Sign In"),
                ),
              ),
            ),
            SizedBox(height: Demensions.screenHeight * 0.025),
            RichText(
              text: TextSpan(
                text: "No account?",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: Demensions.font16,
                ),
                children: [
                  TextSpan(
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => Get.to(
                            () => SignUpView(),
                            transition: Transition.fadeIn,
                          ),
                    text: "Register",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: primaryColor300,
                      fontSize: Demensions.font20,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: Demensions.screenHeight * 0.025),
            RichText(
              text: TextSpan(
                text: "Choose role to sign up or sign in the following methods",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: Demensions.font16,
                ),
              ),
            ),
            SizedBox(height: Demensions.screenHeight * 0.0025),
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
            SizedBox(height: Demensions.screenHeight * 0.0025),
            RichText(
              text: TextSpan(
                text: "Sign in using one of the following methods",
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: Demensions.font16,
                ),
              ),
            ),
            Wrap(
              children: List.generate(
                signUpImg.length,
                (index) => GestureDetector(
                  onTap: index == 0
                      ? _signInOrSignUpWithFacebook
                      : index == 1
                          ? _signInOrSignUpWithGoogle
                          : null,
                  child: CircleAvatar(
                    radius: Demensions.radius30,
                    backgroundImage:
                        AssetImage("assets/images/" + signUpImg[index]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
