import 'package:code2/controllers/cart_field_ctrl.dart';
import 'package:code2/models/demensions.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/repos/sport_field_repo.dart';
import 'package:code2/theme.dart';

import '../route/route_view.dart';

class SportFieldCard extends StatelessWidget {
  final SportFieldRepo field;
  final bool isSelected;
  final void Function(String) onLongPress;

  SportFieldCard(
      {required this.field,
      required this.isSelected,
      required this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          right: Demensions.height10 + 6,
          left: Demensions.height10 + 6,
          top: Demensions.height10 - 6,
          bottom: Demensions.height10 + 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(Demensions.radius16),
        onTap: () {
          Get.lazyPut(() => CartFieldCtrl());
          Get.toNamed(RouteView.getFieldBook(field.id));
        },
        onLongPress: () => onLongPress(field.id),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Demensions.radius16),
                color: isSelected ? Colors.grey[300] : colorWhite,
                boxShadow: [
                  BoxShadow(
                    color: primaryColor500.withOpacity(0.1),
                    blurRadius: Demensions.radius20,
                  )
                ],
              ),
              child: Column(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(borderRadiusSize1)),
                    child: Image.network(field.image,
                        height: Demensions.height20 * 10,
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover),
                  ),
                  Container(
                    padding: EdgeInsets.all(Demensions.height10 + 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(field.spname,
                            maxLines: 2,
                            style: subTitleTextStyle,
                            overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset("assets/images/pin.png",
                                width: 20, height: 20, color: primaryColor500),
                            const SizedBox(width: 8.0),
                            Flexible(
                              child: Text(field.address,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: addressTextStyle),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
