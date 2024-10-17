import 'package:flutter/cupertino.dart';
import 'package:code2/theme.dart';

class BigText5 extends StatelessWidget {
  final String text;
  TextOverflow overflow;

  BigText5(
      {super.key, required this.text, this.overflow = TextOverflow.ellipsis});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: overflow,
      style: descTextStyle7,
    );
  }
}
