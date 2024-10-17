import 'package:code2/controllers/location_ctrl.dart';
import 'package:code2/controllers/sport_field_ctrl.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/cart_field_ctrl.dart';
import '../models/demensions.dart';
import '../theme.dart';
import 'big_text3.dart';
import 'icon_and_text_widget.dart';

class AppColumn extends StatefulWidget {
  final String text;
  final double rating;
  final int commentCount;
  final String id;

  const AppColumn({
    super.key,
    required this.text,
    required this.rating,
    required this.commentCount,
    required this.id,
  });

  @override
  _AppColumnState createState() => _AppColumnState();
}

class _AppColumnState extends State<AppColumn> {
  double? distance;
  Duration? timeToTravel;

  @override
  void initState() {
    super.initState();
    _calculateDistance();
  }

  Duration _estimateTravelTime(double distance, double speedKmPerHour) {
    double timeInHours = distance / speedKmPerHour;
    return Duration(minutes: (timeInHours * 60).toInt());
  }

  Future<void> _calculateDistance() async {
    final user = FirebaseAuth.instance.currentUser;
    final LocationCtrl locationCtrl = Get.find();
    final SportFieldCtrl sportFieldCtrl = Get.find();

    final start = await locationCtrl.getStartPoint(user!.uid);
    final end = await sportFieldCtrl.getendLocation(widget.id);

    final calculatedDistance =
        locationCtrl.calculateDistance(start, end) / 1000;

    final travelTime = _estimateTravelTime(calculatedDistance, 50);

    setState(() {
      distance = calculatedDistance;
      timeToTravel = travelTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      widget.commentCount;
      widget.rating;
    });

    final CartFieldCtrl cartFieldCtrl = Get.find();

    int fullStars = widget.rating.floor();
    bool hasHalfStar = (widget.rating - fullStars) >= 0.5;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BigText3(text: widget.text),
        SizedBox(height: Demensions.height10),
        Row(
          children: [
            Wrap(
              children: List.generate(5, (index) {
                if (index < fullStars) {
                  return Icon(Icons.star,
                      color: primaryColor200, size: Demensions.height20);
                } else if (index == fullStars && hasHalfStar) {
                  return Icon(Icons.star_half,
                      color: primaryColor200, size: Demensions.height20);
                } else {
                  return Icon(Icons.star_border,
                      color: primaryColor200, size: Demensions.height20);
                }
              }),
            ),
            SizedBox(width: Demensions.width10),
            SmallText(text: widget.rating.toStringAsFixed(1)),
            SizedBox(width: Demensions.width10),
            SmallText(text: widget.commentCount.toString()),
            SizedBox(width: Demensions.width10),
            Icon(Icons.comment,
                color: primaryColor200, size: Demensions.height20),
          ],
        ),
        SizedBox(height: Demensions.height20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconAndTextWidget(
              icon: Icons.circle_sharp,
              text: cartFieldCtrl.getBookingStatus(widget.id),
              iconColor: cartFieldCtrl.isCurrentlyBooked(widget.id)
                  ? Colors.red
                  : Colors.green,
            ),
            IconAndTextWidget(
              icon: Icons.location_on,
              text: distance != null
                  ? (distance!.toStringAsFixed(1).length > 3
                      ? "${distance!.toStringAsFixed(1).substring(0, 3)}..."
                      : distance!.toStringAsFixed(1))
                  : "0.0",
              iconColor: primaryColor200,
            ),
            IconAndTextWidget(
              icon: Icons.access_time_rounded,
              text: timeToTravel != null
                  ? "${timeToTravel!.inMinutes} min"
                  : "0 min",
              iconColor: colorRed,
            ),
          ],
        )
      ],
    );
  }
}
