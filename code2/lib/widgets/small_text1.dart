import 'package:flutter/cupertino.dart';
import 'package:code2/theme.dart';

class SmallText1 extends StatelessWidget {
  final String text;

  SmallText1({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: descTextStyle3,
    );
  }
}
