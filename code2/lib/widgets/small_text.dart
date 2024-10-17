import 'package:flutter/cupertino.dart';
import 'package:code2/theme.dart';

class SmallText extends StatelessWidget {
  final String text;

  SmallText({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: descTextStyle,
    );
  }
}
