import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/big_text.dart';

void showErrorScBar(String msg, {bool isError = true, String title = "Error"}) {
  Get.snackbar(title, msg,
      titleText: BigText(text: title),
      messageText: Text(
        msg,
        style: const TextStyle(color: Colors.white),
      ),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.redAccent);
}
