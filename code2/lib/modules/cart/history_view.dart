import 'package:code2/components/empty_data_view.dart';
import 'package:code2/controllers/checkout_ctrl.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/app_icon.dart';
import 'package:code2/widgets/big_text4.dart';
import 'package:code2/widgets/big_text7.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:code2/widgets/small_text2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/cart_field_ctrl.dart';
import '../../controllers/sport_field_ctrl.dart';
import '../../data/repos/cart_field_repo.dart';
import '../../route/route_view.dart';

class HistoryView extends StatelessWidget {
  const HistoryView({super.key});

  DateTime findValidDate(DateTime currentDate, DateTime firstDate,
      DateTime lastDate, String openDay) {
    while (currentDate.isBefore(lastDate)) {
      if (isSelectable(currentDate, openDay)) {
        return currentDate;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }
    return firstDate;
  }

  bool isSelectable(DateTime date, String openDay) {
    if (openDay.toLowerCase() == 'all day') {
      return true;
    } else {
      int startDayIndex = getDayIndex(openDay.split(' to ').first);
      int endDayIndex = getDayIndex(openDay.split(' to ').last);
      int dayIndex = date.weekday;
      return dayIndex >= startDayIndex && dayIndex <= endDayIndex;
    }
  }

  int getDayIndex(String day) {
    switch (day.toLowerCase()) {
      case 'monday':
        return 1;
      case 'tuesday':
        return 2;
      case 'wednesday':
        return 3;
      case 'thursday':
        return 4;
      case 'friday':
        return 5;
      case 'saturday':
        return 6;
      case 'sunday':
        return 7;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => CheckoutCtrl());
    final CheckoutCtrl checkoutCtrl = Get.find();
    final SportFieldCtrl sportFieldCtrl = Get.find();
    DateTime now = DateTime.now();

    DateTime validDate = isSelectable(now, sportFieldCtrl.openDay.value)
        ? now
        : findValidDate(now, now, now.add(Duration(days: 365)),
            sportFieldCtrl.openDay.value);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkoutCtrl.fetchData();
    });

    return Scaffold(
      body: Column(
        children: [
          Container(
            color: primaryColor500,
            height: Demensions.height10 * 10,
            width: double.maxFinite,
            padding: EdgeInsets.only(top: Demensions.height45),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BigText7(text: "History Checkout"),
                AppIcon(
                  icon: Icons.shopping_cart_outlined,
                  iconColor: primaryColor500,
                  backgroundColor: Colors.yellow,
                ),
              ],
            ),
          ),
          GetBuilder<CheckoutCtrl>(builder: (_CheckCtrl) {
            return _CheckCtrl.items.length > 0
                ? Expanded(
                    child: Obx(() {
                      if (checkoutCtrl.items.isEmpty) {
                        return Center(child: CircularProgressIndicator());
                      }
                      return Container(
                        margin: EdgeInsets.only(
                          top: Demensions.height20,
                          left: Demensions.width20,
                          right: Demensions.width20,
                        ),
                        child: MediaQuery.removePadding(
                          removeTop: true,
                          context: context,
                          child: ListView.builder(
                            itemCount: checkoutCtrl.items.length,
                            itemBuilder: (context, index) {
                              final checkoutItem = checkoutCtrl.items[index];
                              final itemCount = checkoutItem.items.length;
                              final totalAmount = checkoutItem.items
                                  .map((item) => item.price)
                                  .reduce((value, element) => value + element);
                              return Container(
                                height: Demensions.height30 * 4.2,
                                margin: EdgeInsets.only(
                                    bottom: Demensions.height20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    BigText4(
                                      text: checkoutItem.timestamp != null
                                          ? DateTime.fromMillisecondsSinceEpoch(
                                                  checkoutItem.timestamp!
                                                      .millisecondsSinceEpoch)
                                              .toLocal()
                                              .toString()
                                              .split('.')[0]
                                          : 'Date not available',
                                    ),
                                    SizedBox(height: Demensions.height10),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Wrap(
                                          direction: Axis.horizontal,
                                          children: List.generate(
                                            itemCount,
                                            (i) => i < 2
                                                ? Container(
                                                    height:
                                                        Demensions.height20 * 4,
                                                    width:
                                                        Demensions.width20 * 4,
                                                    margin: EdgeInsets.only(
                                                        right:
                                                            Demensions.width20 /
                                                                2),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius
                                                          .circular(Demensions
                                                                  .radius16 /
                                                              2),
                                                      image: DecorationImage(
                                                        fit: BoxFit.cover,
                                                        image: NetworkImage(
                                                            checkoutCtrl.getImage(
                                                                checkoutItem
                                                                    .items[i]
                                                                    .sportFieldId)),
                                                      ),
                                                    ),
                                                  )
                                                : Container(),
                                          ),
                                        ),
                                        Container(
                                          height: Demensions.height20 * 4.3,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              SmallText(
                                                  text:
                                                      "Total: \$${totalAmount.toStringAsFixed(2)}"),
                                              BigText4(
                                                  text: "${itemCount} item(s)"),
                                              GestureDetector(
                                                onTap: () {
                                                  for (var item
                                                      in checkoutItem.items) {
                                                    final cartItem =
                                                        CartFieldRepo(
                                                      id: item.id,
                                                      spname: item.name,
                                                      image: checkoutCtrl
                                                          .getImage(item
                                                              .sportFieldId),
                                                      price: item.price.toInt(),
                                                      sport_id:
                                                          item.sportFieldId,
                                                      Time: item.time,
                                                      isBook: false,
                                                      userID:
                                                          checkoutItem.userID,
                                                      DatePick: DateFormat(
                                                              'EEEE, dd MMM yyyy')
                                                          .format(validDate),
                                                    );

                                                    final cartFieldCtrl = Get
                                                        .find<CartFieldCtrl>();
                                                    cartFieldCtrl
                                                        .addBooking(cartItem);
                                                  }

                                                  Get.toNamed(
                                                      RouteView.getCartView());
                                                },
                                                child: Container(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          Demensions.width10,
                                                      vertical:
                                                          Demensions.height10 /
                                                              2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            Demensions
                                                                    .radius16 /
                                                                3),
                                                    border: Border.all(
                                                        width: 1,
                                                        color: primaryColor500),
                                                  ),
                                                  child: SmallText2(
                                                      text: "One more"),
                                                ),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    }),
                  )
                : Container(
                    height: MediaQuery.of(context).size.height / 1.5,
                    child: const Center(
                        child: EmptyDataView(
                            text: "History is Empty",
                            imgEmpty:
                                "assets/images/no_transaction_illustration.png")),
                  );
          })
        ],
      ),
    );
  }
}
