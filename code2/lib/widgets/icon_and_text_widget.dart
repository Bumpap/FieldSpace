import 'package:code2/models/demensions.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';

class IconAndTextWidget extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;

  const IconAndTextWidget(
      {super.key,
      required this.icon,
      required this.text,
      required this.iconColor});

  @override
  Widget build(BuildContext context) {
    double width =
        text == "NBooked" ? Demensions.width10 - 8 : Demensions.width10 - 5;

    return Row(
      children: [
        Icon(
          icon,
          color: iconColor,
        ),
        SizedBox(
          width: width,
        ),
        SmallText(
          text: text,
        ),
      ],
    );
  }
}
