import 'package:code2/route/route_view.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import "../theme.dart";
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'helper/dependencies.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseAuth.instance.signOut();
  GoogleSignIn googleSignIn = GoogleSignIn();
  googleSignIn.signOut();
  Dependencies.init();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FieldSpace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: primaryColor500,
          fontFamily: "Lato",
          primarySwatch: createMaterialColor(Colors.white),
          canvasColor: colorWhite),
      initialRoute: RouteView.getSpashView(),
      getPages: RouteView.routes,
    );
  }
}
