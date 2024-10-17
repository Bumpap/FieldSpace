import 'package:code2/models/demensions.dart';
import 'package:code2/modules/home/sport_field_body.dart';
import 'package:code2/modules/recommended/recommend_field_view.dart';
import 'package:code2/widgets/big_text1.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:code2/theme.dart';
import 'package:get/get.dart';
import '../../controllers/categories_sport_ctrl.dart';
import '../../controllers/sport_field_ctrl.dart';
import '../account/user_profile.dart';
import '../search&managefield/search_view.dart';
import 'category_cart.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final SportFieldCtrl sportFieldCtrl = Get.find();
  final CategoriesSportCtrl categoriesSportCtrl = Get.find();

  Future<void> _loadResource() async {
    sportFieldCtrl.fetchData();
    categoriesSportCtrl.fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
        child: Column(
          children: [
            Container(
                child: Container(
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
                  Container(
                    width: Demensions.height45,
                    height: Demensions.height45,
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return SearchView(
                            selectedDropdownItem: "",
                          );
                        }));
                      },
                      icon: const Icon(Icons.search, color: colorWhite),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadiusSize),
                      color: primaryColor500,
                    ),
                  )
                ],
              ),
            )),
            Expanded(
                child: ListView(
              padding: EdgeInsets.zero,
              children: [
                CategoryListView(),
                Padding(
                  padding: EdgeInsets.only(
                      top: Demensions.height10 - 2,
                      left: Demensions.width10 + 6,
                      right: Demensions.width10 + 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      BigText1(text: "Recommended Fields"),
                      TextButton(
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return RecommendFieldView();
                            }));
                          },
                          child: const Text("Show All"))
                    ],
                  ),
                ),
                SportFieldBody(),
              ],
            ))
          ],
        ),
        onRefresh: _loadResource);
  }
}
