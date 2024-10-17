import 'package:flutter/cupertino.dart';
import 'package:code2/theme.dart';

class BigText1 extends StatelessWidget {
  final String text;
  TextOverflow overflow;

  BigText1(
      {super.key, required this.text, this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: overflow,
      style: titleTextStyle1,
    );
  }
}
