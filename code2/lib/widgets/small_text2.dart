import 'package:flutter/cupertino.dart';
import 'package:code2/theme.dart';

class SmallText2 extends StatelessWidget {
  final String text;

  SmallText2({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: descTextStyle6,
    );
  }
}
