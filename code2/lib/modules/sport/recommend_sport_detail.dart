import 'package:code2/controllers/sport_field_ctrl.dart';
import 'package:code2/route/route_view.dart';
import 'package:code2/widgets/app_icon.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart_field_ctrl.dart';
import '../../controllers/recommend_ctrl.dart';
import '../../models/demensions.dart';
import '../../theme.dart';
import '../../widgets/big_text4.dart';
import '../../widgets/expandable_text_widget.dart';

class RecommendSportDetail extends StatelessWidget {
  final String id;

  RecommendSportDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context) {
    final SportFieldCtrl controller = Get.find();
    final RecommendCtrl recommendCtrl = Get.find();
    var sport = controller.getFieldByIdFromItems(id);

    if (sport == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Not Found')),
        body: Center(child: Text('Sport field not found')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            automaticallyImplyLeading: false,
            toolbarHeight: Demensions.height10 * 7,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteView.getHome());
                  },
                  child: AppIcon(icon: Icons.clear),
                ),
              ],
            ),
            bottom: PreferredSize(
              preferredSize: Size.fromHeight(Demensions.height20),
              child: Container(
                width: double.maxFinite,
                padding: EdgeInsets.only(
                    top: Demensions.height10 / 2, bottom: Demensions.height10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(Demensions.radius20),
                    topRight: Radius.circular(Demensions.radius20),
                  ),
                ),
                child: Center(child: BigText4(text: sport.spname)),
              ),
            ),
            pinned: true,
            backgroundColor: Colors.green,
            expandedHeight: 300,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                sport.image,
                width: double.maxFinite,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: Demensions.width20),
              child: ExpandableTextWidget(
                text: "Author: ${sport.author}\n"
                    "Address: ${sport.address}\n"
                    "Open Day: ${sport.openDay}\n"
                    "Open Time: ${DateFormat('yyyy-MM-dd').format(sport.openTime.toDate()).toString()}\n"
                    "Close Time: ${DateFormat('yyyy-MM-dd').format(sport.closeTime.toDate()).toString()}\n"
                    "Phone Number: ${sport.phoneNumber.toString()}\n"
                    "Price: ${sport.price}",
                id: id,
                comments: recommendCtrl.commentsMap[id] ?? [],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: Demensions.bottomHeightBar,
        padding: EdgeInsets.symmetric(
            vertical: Demensions.height30, horizontal: Demensions.width20),
        decoration: BoxDecoration(
          color: darkBlue500,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(Demensions.radius20 * 2),
            topRight: Radius.circular(Demensions.radius20 * 2),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Get.toNamed(RouteView.getRecommendedDetail(id));
              },
              child: Container(
                padding: EdgeInsets.all(Demensions.height20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Demensions.radius20),
                  color: Colors.white,
                ),
                child: Icon(Icons.favorite, color: Colors.greenAccent),
              ),
            ),
            GestureDetector(
              onTap: () {
                Get.lazyPut(() => CartFieldCtrl());
                Get.toNamed(RouteView.getFieldBook(id));
              },
              child: Container(
                padding: EdgeInsets.all(Demensions.height20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Demensions.radius20),
                  color: primaryColor200,
                ),
                child: BigText4(text: "Booking"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
