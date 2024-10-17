import 'package:code2/models/demensions.dart';
import 'package:code2/widgets/app_icon.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:flutter/material.dart';

class PersonProfileWidget extends StatelessWidget {
  final AppIcon appIcon;
  final SmallText smallText;
  final IconData? editIcon;
  final VoidCallback? onEdit;

  const PersonProfileWidget({
    Key? key,
    required this.smallText,
    required this.appIcon,
    this.editIcon,
    this.onEdit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: Demensions.width20,
        top: Demensions.width10,
        bottom: Demensions.width10,
        right: Demensions.width20,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              appIcon,
              SizedBox(width: Demensions.width20),
              smallText,
            ],
          ),
          if (editIcon != null)
            GestureDetector(
              onTap: onEdit,
              child: Icon(
                editIcon,
                color: Colors.grey,
                size: Demensions.height10 * 3,
              ),
            ),
        ],
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            blurRadius: 1,
            offset: Offset(0, 5),
            color: Colors.grey.withOpacity(0.2),
          ),
        ],
      ),
    );
  }
}
