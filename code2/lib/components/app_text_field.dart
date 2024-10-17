import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/demensions.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController txtCtrl;
  final String hintTxt;
  final IconData iconData;
  final bool isObs;
  final Function()? suffixIconOnTap;
  final bool obscureText;

  const AppTextField({
    super.key,
    required this.txtCtrl,
    required this.hintTxt,
    required this.iconData,
    this.isObs = false,
    this.suffixIconOnTap,
    this.obscureText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          left: Demensions.height20, right: Demensions.height20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(Demensions.radius30),
        boxShadow: [
          BoxShadow(
            blurRadius: 10,
            spreadRadius: 7,
            offset: Offset(1, 10),
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
      child: TextField(
        controller: txtCtrl,
        obscureText: isObs ? obscureText : false,
        decoration: InputDecoration(
          hintText: hintTxt,
          prefixIcon: Icon(
            iconData,
            color: Colors.red,
          ),
          suffixIcon: isObs
              ? GestureDetector(
                  onTap: suffixIconOnTap,
                  child: Icon(
                    obscureText ? Icons.visibility_off : Icons.visibility,
                  ),
                )
              : null,
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Demensions.radius30),
            borderSide: BorderSide(
              width: 1.0,
              color: Colors.white,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Demensions.radius30),
            borderSide: BorderSide(
              width: 1.0,
              color: Colors.white,
            ),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(Demensions.radius30),
          ),
        ),
      ),
    );
  }
}
