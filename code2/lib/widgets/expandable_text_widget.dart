import 'package:code2/models/demensions.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:code2/widgets/small_text2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme.dart';

class ExpandableTextWidget extends StatefulWidget {
  final String text;
  final String id;
  final List<Map<String, dynamic>> comments;

  const ExpandableTextWidget({
    Key? key,
    required this.text,
    required this.id,
    required this.comments,
  }) : super(key: key);

  @override
  State<ExpandableTextWidget> createState() => _ExpandableTextWidgetState();
}

class _ExpandableTextWidgetState extends State<ExpandableTextWidget> {
  late String firstHalf;
  late String secondHalf;
  final RxBool hiddenText = true.obs;
  double textHeight = Demensions.screenHeight / 5.63;

  @override
  void initState() {
    super.initState();
    if (widget.text.length > textHeight) {
      firstHalf = widget.text.substring(0, textHeight.toInt());
      secondHalf =
          widget.text.substring(textHeight.toInt() + 1, widget.text.length);
    } else {
      firstHalf = widget.text;
      secondHalf = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(() {
          return SmallText(
            text: hiddenText.value
                ? (firstHalf + "...")
                : (firstHalf + secondHalf),
          );
        }),
        if (!hiddenText.value) ...[
          SmallText2(text: "Comment"),
          ...widget.comments
              .map((comment) => SmallText(text: comment['comment'] ?? ''))
              .toList(),
        ],
        InkWell(
          onTap: () {
            hiddenText.value = !hiddenText.value;
          },
          child: Row(
            children: [
              Obx(() {
                return SmallText2(
                    text: hiddenText.value ? "Show more" : "Show less");
              }),
              Obx(() {
                return Icon(
                  hiddenText.value
                      ? Icons.arrow_drop_down
                      : Icons.arrow_drop_up,
                  color: primaryColor500,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
