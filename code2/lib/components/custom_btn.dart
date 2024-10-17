import 'package:code2/models/demensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomBtn extends StatelessWidget {
  final VoidCallback? onPress;
  final String btnTxt;
  final bool transparent;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final double? fontSize;
  final double radius;
  final IconData? icon;

  const CustomBtn(
      {super.key,
      this.onPress,
      required this.btnTxt,
      this.transparent = false,
      this.margin,
      this.height,
      this.width,
      this.fontSize,
      this.radius = 5,
      this.icon});

  @override
  Widget build(BuildContext context) {
    final ButtonStyle _fBtn = TextButton.styleFrom(
        backgroundColor: onPress == null
            ? Theme.of(context).disabledColor
            : transparent
                ? Colors.transparent
                : Theme.of(context).primaryColor,
        minimumSize: Size(width == null ? Demensions.screenWidth : width!,
            height != null ? height! : 50),
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radius)));
    return Center(
      child: SizedBox(
        width: width ?? Demensions.screenWidth,
        height: height ?? 50,
        child: TextButton(
          onPressed: onPress,
          style: _fBtn,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null
                  ? Padding(
                      padding: EdgeInsets.only(
                        right: Demensions.width10 / 2,
                      ),
                      child: Icon(
                        icon,
                        color: transparent
                            ? Theme.of(context).primaryColor
                            : Theme.of(context).cardColor,
                      ),
                    )
                  : SizedBox(),
              Text(
                btnTxt ?? "",
                style: TextStyle(
                  fontSize: fontSize != null ? fontSize : Demensions.font16,
                  color: transparent
                      ? Theme.of(context).primaryColor
                      : Theme.of(context).cardColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
