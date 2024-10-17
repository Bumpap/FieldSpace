import 'package:code2/models/demensions.dart';
import 'package:code2/modules/search&managefield/manage_field.dart';
import 'package:code2/theme.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import '../../controllers/categories_sport_ctrl.dart';

class CategoryListView extends StatelessWidget {
  const CategoryListView({super.key});

  @override
  Widget build(BuildContext context) {
    final CategoriesSportCtrl categoriesCtrl = Get.find();

    return Obx(() {
      if (categoriesCtrl.items.isEmpty) {
        return Center(
          child: CircularProgressIndicator(),
        );
      } else {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: categoriesCtrl.items.map((category) {
                return CategoryCard(
                  title: category.spname,
                  imageAsset: category.image,
                  cateid: category.id,
                );
              }).toList(),
            ),
          ),
        );
      }
    });
  }
}

class CategoryCard extends StatelessWidget {
  final String title;
  final String imageAsset;
  final String cateid;

  CategoryCard(
      {required this.title, required this.imageAsset, required this.cateid});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: Demensions.height15 + 1,
          horizontal: Demensions.width10 - 2),
      child: Material(
        color: colorWhite,
        shadowColor: primaryColor500.withOpacity(0.1),
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: InkWell(
          highlightColor: primaryColor500.withOpacity(0.1),
          borderRadius: BorderRadius.circular(Demensions.radius16),
          splashColor: primaryColor500.withOpacity(0.5),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) {
              return ManageField(cateid: cateid);
            }));
          },
          child: Container(
            padding: EdgeInsets.all(Demensions.radius16),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: Demensions.height15 + 1),
                  child: CircleAvatar(
                    radius: Demensions.radius30,
                    backgroundColor: primaryColor100,
                    child: Image.network(
                      imageAsset,
                      color: darkBlue500,
                      width: Demensions.width10 * 5,
                      height: Demensions.height10 * 5,
                    ),
                  ),
                ),
                SizedBox(
                  height: Demensions.height10 - 2,
                ),
                Text(
                  title,
                  style: descTextStyle,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
