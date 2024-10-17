import 'package:flutter/material.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/big_text4.dart';
import 'package:get/get.dart';
import '../../components/empty_data_view.dart';
import '../../components/transaction_details_view.dart';
import '../../controllers/checkout_ctrl.dart';
import '../../widgets/big_text1.dart';
import '../../widgets/small_text.dart';
import '../../widgets/small_text2.dart';

class HistoryAdminView extends StatelessWidget {
  const HistoryAdminView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CheckoutCtrl());
    final CheckoutCtrl checkoutAdminCtrl = Get.find();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkoutAdminCtrl.fetchAllData();
    });

    return Scaffold(
      appBar: AppBar(
        title: BigText1(text: "History Checkout"),
        backgroundColor: primaryColor500,
      ),
      body: GetBuilder<CheckoutCtrl>(builder: (_CheckCtrl) {
        return _CheckCtrl.allItems.isNotEmpty
            ? Obx(() {
                if (checkoutAdminCtrl.allItems.isEmpty) {
                  return Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                  padding: EdgeInsets.all(Demensions.width20),
                  itemCount: checkoutAdminCtrl.allItems.length,
                  itemBuilder: (context, index) {
                    final checkoutItem = checkoutAdminCtrl.allItems[index];
                    final itemCount = checkoutItem.items.length;
                    final totalAmount = checkoutItem.items
                        .map((item) => item.price)
                        .reduce((value, element) => value + element);

                    return Container(
                      padding: EdgeInsets.all(Demensions.height10),
                      margin: EdgeInsets.only(bottom: Demensions.height20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(Demensions.radius16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            blurRadius: 5,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          BigText4(
                            text: checkoutItem.timestamp != null
                                ? DateTime
                                            .fromMillisecondsSinceEpoch(
                                                checkoutItem.timestamp!
                                                    .millisecondsSinceEpoch)
                                        .toLocal()
                                        .toString()
                                        .split('.')[
                                    0] // Formatting as YYYY-MM-DD HH:MM
                                : 'Date not available',
                          ),
                          SizedBox(height: Demensions.height10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Wrap(
                                direction: Axis.horizontal,
                                children: List.generate(
                                  itemCount,
                                  (i) => i < 2
                                      ? Container(
                                          height: Demensions.height20 * 4,
                                          width: Demensions.width20 * 4,
                                          margin: EdgeInsets.only(
                                              right: Demensions.width20 / 2),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                                Demensions.radius16 / 2),
                                            image: DecorationImage(
                                              fit: BoxFit.cover,
                                              image: NetworkImage(
                                                checkoutAdminCtrl.getAllImage(
                                                    checkoutItem
                                                        .items[i].sportFieldId),
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  SmallText(
                                      text:
                                          "Total: \$${totalAmount.toStringAsFixed(2)}"),
                                  BigText4(text: "$itemCount item(s)"),
                                  GestureDetector(
                                    onTap: () {
                                      Get.to(
                                          TransactionDetailsView(
                                              transaction: checkoutItem),
                                          transition: Transition.fadeIn);
                                    },
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: Demensions.width10,
                                          vertical: Demensions.height10 / 2),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            Demensions.radius16 / 3),
                                        border: Border.all(
                                            width: 1, color: primaryColor500),
                                      ),
                                      child: SmallText2(text: "See more"),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              })
            : Container(
                height: MediaQuery.of(context).size.height / 1.5,
                child: const Center(
                  child: EmptyDataView(
                    text: "History is Empty",
                    imgEmpty: "assets/images/no_transaction_illustration.png",
                  ),
                ),
              );
      }),
    );
  }
}
