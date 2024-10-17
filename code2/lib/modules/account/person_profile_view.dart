import 'package:code2/controllers/location_ctrl.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/route/route_view.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/app_icon.dart';
import 'package:code2/widgets/big_text7.dart';
import 'package:code2/widgets/person_profile_widget.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/users_ctrl.dart';

class PersonProfileView extends StatelessWidget {
  const PersonProfileView({super.key});

  void _showImagePicker(BuildContext context, UsersCtrl usersCtrl) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: Icon(Icons.photo_library),
                  title: Text('Photo Library'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    String? imageName = await usersCtrl.uploadProfileImage(
                        source: ImageSource.gallery);
                    if (imageName != null) {
                      usersCtrl.updateProfileImageName(imageName);
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.photo_camera),
                  title: Text('Camera'),
                  onTap: () async {
                    Navigator.of(context).pop();

                    String? imageName = await usersCtrl.uploadProfileImage(
                        source: ImageSource.camera);
                    if (imageName != null) {
                      usersCtrl.updateProfileImageName(imageName);
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(BuildContext context, String title, String currentValue,
      Function(String) onSave) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Enter new $title',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                onSave(controller.text);
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final UsersCtrl usersCtrl = Get.find<UsersCtrl>();
    final LocationCtrl locationCtrl = Get.find<LocationCtrl>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      locationCtrl.onInit();
      locationCtrl.fetchData();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor500,
        centerTitle: true,
        title: BigText7(text: "Profile"),
      ),
      body: Obx(() {
        final user = usersCtrl.currentUser.value;
        final imageName = usersCtrl.imageName.value;
        final addresses = locationCtrl.address;

        return user == null
            ? Container(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: double.maxFinite,
                        height: Demensions.height45 * 9,
                        margin: EdgeInsets.only(
                            left: Demensions.width20,
                            right: Demensions.width20),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(Demensions.radius20),
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image: AssetImage(
                                  "assets/images/onboarding_illustration.png")),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(RouteView.getSignInView());
                        },
                        child: Container(
                          width: double.maxFinite,
                          height: Demensions.height20 * 5,
                          margin: EdgeInsets.only(
                              left: Demensions.width20,
                              right: Demensions.width20),
                          decoration: BoxDecoration(
                            color: primaryColor500,
                            borderRadius:
                                BorderRadius.circular(Demensions.radius20),
                          ),
                          child: Center(
                            child: BigText7(
                              text: "Sign in",
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Container(
                width: double.maxFinite,
                margin: EdgeInsets.only(top: Demensions.height20),
                child: Column(
                  children: [
                    // profile icon
                    user.imagePro.isNotEmpty
                        ? CircleAvatar(
                            radius: Demensions.height15 * 5,
                            backgroundImage: NetworkImage(user.imagePro),
                          )
                        : AppIcon(
                            icon: Icons.person,
                            iconColor: Colors.white,
                            backgroundColor: primaryColor500,
                            size: Demensions.height15 * 10,
                            iconSize: Demensions.height30 + Demensions.height45,
                          ),
                    SizedBox(height: Demensions.height20),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            // name
                            PersonProfileWidget(
                              smallText: SmallText(text: user.name),
                              appIcon: AppIcon(
                                icon: Icons.person,
                                iconColor: Colors.white,
                                backgroundColor: primaryColor500,
                                size: Demensions.height10 * 5,
                                iconSize: Demensions.height10 * 5 / 2,
                              ),
                              editIcon: Icons.edit,
                              onEdit: () {
                                _showEditDialog(
                                  context,
                                  'Name',
                                  user.name,
                                  (newValue) {
                                    usersCtrl.updateUserName(newValue);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: Demensions.height20),
                            // phone
                            PersonProfileWidget(
                              smallText: SmallText(text: user.phoneNb),
                              appIcon: AppIcon(
                                icon: Icons.phone,
                                iconColor: Colors.white,
                                backgroundColor: Colors.yellow,
                                size: Demensions.height10 * 5,
                                iconSize: Demensions.height10 * 5 / 2,
                              ),
                              editIcon: Icons.edit,
                              onEdit: () {
                                _showEditDialog(
                                  context,
                                  'Phone Number',
                                  user.phoneNb,
                                  (newValue) {
                                    usersCtrl.updateUserPhone(newValue);
                                  },
                                );
                              },
                            ),
                            SizedBox(height: Demensions.height20),
                            // email
                            PersonProfileWidget(
                              smallText: SmallText(text: user.email),
                              appIcon: AppIcon(
                                icon: Icons.email,
                                iconColor: Colors.white,
                                backgroundColor: Colors.red,
                                size: Demensions.height10 * 5,
                                iconSize: Demensions.height10 * 5 / 2,
                              ),
                            ),
                            SizedBox(height: Demensions.height20),
                            // address
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteView.getAddress());
                              },
                              child: PersonProfileWidget(
                                smallText: SmallText(
                                  text: addresses.isEmpty
                                      ? "No address"
                                      : addresses.first.address,
                                ),
                                appIcon: AppIcon(
                                  icon: Icons.location_on,
                                  iconColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  size: Demensions.height10 * 5,
                                  iconSize: Demensions.height10 * 5 / 2,
                                ),
                              ),
                            ),
                            SizedBox(height: Demensions.height20),
                            GestureDetector(
                              onTap: () {
                                _showImagePicker(context, usersCtrl);
                              },
                              child: PersonProfileWidget(
                                smallText: SmallText(
                                  text: imageName.isEmpty
                                      ? "Upload Image"
                                      : imageName.endsWith('.jpg')
                                          ? imageName
                                          : imageName.length > 10
                                              ? '${imageName.substring(0, 10)}...'
                                              : imageName,
                                ),
                                appIcon: AppIcon(
                                  icon: Icons.upload,
                                  iconColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  size: Demensions.height10 * 5,
                                  iconSize: Demensions.height10 * 5 / 2,
                                ),
                              ),
                            ),
                            SizedBox(height: Demensions.height20),
                            GestureDetector(
                              onTap: () {
                                Get.toNamed(RouteView.getChangePassWordView());
                              },
                              child: PersonProfileWidget(
                                smallText: SmallText(text: "Change Password"),
                                appIcon: AppIcon(
                                  icon: Icons.lock,
                                  iconColor: Colors.white,
                                  backgroundColor: Colors.green,
                                  size: Demensions.height10 * 5,
                                  iconSize: Demensions.height10 * 5 / 2,
                                ),
                              ),
                            ),
                            SizedBox(height: Demensions.height20),
                            GestureDetector(
                              onTap: () {
                                usersCtrl.logout();
                                Get.offNamed(RouteView.getSignInView());
                                Get.toNamed(RouteView.getSignInView());
                              },
                              child: PersonProfileWidget(
                                smallText: SmallText(text: "Log out"),
                                appIcon: AppIcon(
                                  icon: Icons.logout_rounded,
                                  iconColor: Colors.white,
                                  backgroundColor: Colors.pink,
                                  size: Demensions.height10 * 5,
                                  iconSize: Demensions.height10 * 5 / 2,
                                ),
                              ),
                            ),
                            SizedBox(height: Demensions.height20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }
}
