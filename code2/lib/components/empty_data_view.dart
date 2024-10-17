import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EmptyDataView extends StatelessWidget {
  final String text;
  final String imgEmpty;

  const EmptyDataView({super.key, required this.text, required this.imgEmpty});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Image.asset(
          imgEmpty,
          height: MediaQuery.of(context).size.height * 0.22,
          width: MediaQuery.of(context).size.width * 0.22,
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.33,
        ),
        Text(
          text,
          style: TextStyle(
              fontSize: MediaQuery.of(context).size.height * 0.0175,
              color: Theme.of(context).disabledColor),
          textAlign: TextAlign.center,
        )
      ],
    );
  }
}
