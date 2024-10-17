import 'dart:async';

import 'package:code2/models/demensions.dart';
import 'package:code2/route/route_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SpashView extends StatefulWidget {
  const SpashView({super.key});

  @override
  State<SpashView> createState() => _SpashViewState();
}

class _SpashViewState extends State<SpashView> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward();
    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    Timer(Duration(seconds: 3), () => Get.offNamed(RouteView.getHome()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
              scale: animation,
              child: Center(
                  child: Image.asset(
                "assets/images/logo.png",
                width: Demensions.spashImg,
              ))),
          Center(
              child: Image.asset(
            "assets/images/letter_logo.png",
            width: Demensions.spashImg,
          ))
        ],
      ),
    );
  }
}
