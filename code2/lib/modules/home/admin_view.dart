import 'package:code2/models/demensions.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:code2/theme.dart';
import 'package:get/get.dart';
import '../../controllers/categories_sport_ctrl.dart';
import '../../controllers/sport_field_ctrl.dart';
import '../../controllers/users_ctrl.dart';
import '../../route/route_view.dart';
import '../account/user_profile.dart';
import 'category_cart.dart';

class AdminView extends StatefulWidget {
  const AdminView({super.key});

  @override
  State<AdminView> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminView> {
  final SportFieldCtrl sportFieldCtrl = Get.find();
  final CategoriesSportCtrl categoriesSportCtrl = Get.find();

  Future<void> _loadResource() async {
    sportFieldCtrl.fetchData();
    categoriesSportCtrl.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    final UsersCtrl usersCtrl = Get.find<UsersCtrl>();
    return RefreshIndicator(
      onRefresh: _loadResource,
      child: Container(
        color: Colors.white,
        child: Stack(
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(
                      top: Demensions.height45, bottom: Demensions.height15),
                  padding: EdgeInsets.only(
                      left: Demensions.width20, right: Demensions.width20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        children: [UserProfile()],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      CategoryListView(),
                      SizedBox(height: Demensions.height20),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Demensions.width20),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(RouteView.getAccountUser());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor500,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            "Manage Accounts",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Demensions.height20),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: Demensions.width20),
                        child: ElevatedButton(
                          onPressed: () {
                            Get.toNamed(RouteView.getAddminHistory());
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor500,
                            padding: EdgeInsets.symmetric(vertical: 15),
                          ),
                          child: Text(
                            "Manage History Checkout",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: Demensions.height20),
                    ],
                  ),
                ),
              ],
            ),
            Positioned(
              right: Demensions.width20,
              bottom: Demensions.height20,
              child: FloatingActionButton(
                onPressed: () {
                  usersCtrl.logout();
                  Get.offNamed(RouteView.getSignInView());
                  Get.toNamed(RouteView.getSignInView());
                },
                backgroundColor: primaryColor500,
                child: const Icon(Icons.logout, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
