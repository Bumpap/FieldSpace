import 'package:code2/models/demensions.dart';
import 'package:code2/widgets/big_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../widgets/small_text.dart';
import 'package:code2/controllers/users_ctrl.dart';

class UserProfile extends StatelessWidget {
  UserProfile({super.key});

  final UsersCtrl usersCtrl = Get.put(UsersCtrl());

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (usersCtrl.currentUser.value == null) {
        return Row(
          children: [
            Container(
              width: Demensions.width30 + 25,
              height: Demensions.height45 + 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/user_profile_example.png"),
                ),
              ),
            ),
            SizedBox(
              width: Demensions.radius16,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallText(text: "Welcome back,"),
                SizedBox(
                  height: Demensions.height10 - 6,
                ),
                BigText(text: "Please log in"),
              ],
            ),
          ],
        );
      } else {
        var user = usersCtrl.currentUser.value!;
        return Row(
          children: [
            Container(
              width: Demensions.width30 + 25,
              height: Demensions.height45 + 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  fit: BoxFit.fill,
                  image: user.imagePro.isNotEmpty
                      ? NetworkImage(user.imagePro)
                      : const AssetImage(
                              "assets/images/user_profile_example.png")
                          as ImageProvider,
                ),
              ),
            ),
            SizedBox(
              width: Demensions.radius16,
            ),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SmallText(text: "Welcome back,"),
                SizedBox(
                  height: Demensions.height10 - 6,
                ),
                BigText(text: user.name),
              ],
            ),
          ],
        );
      }
    });
  }
}
