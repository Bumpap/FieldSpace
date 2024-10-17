import 'package:flutter/material.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/big_text1.dart';
import 'package:code2/widgets/big_text4.dart';
import 'package:get/get.dart';
import '../../widgets/small_text2.dart';
import '../controllers/checkout_ctrl.dart';

class TransactionDetailsView extends StatelessWidget {
  final dynamic transaction;

  const TransactionDetailsView({Key? key, required this.transaction})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CheckoutCtrl checkoutAdminCtrl = Get.find();
    final totalAmount = transaction.items
        .map((item) => item.price)
        .reduce((value, element) => value + element);

    return Scaffold(
      appBar: AppBar(
        title: BigText1(text: "Transaction Details"),
        backgroundColor: primaryColor500,
      ),
      body: Padding(
        padding: EdgeInsets.all(Demensions.width20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BigText4(
              text: transaction.timestamp != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                          transaction.timestamp!.millisecondsSinceEpoch)
                      .toLocal()
                      .toString()
                      .split('.')[0] // Formatting as YYYY-MM-DD HH:MM
                  : 'Date not available',
            ),
            SizedBox(height: Demensions.height20),
            Expanded(
              child: ListView.builder(
                itemCount: transaction.items.length,
                itemBuilder: (context, index) {
                  final item = transaction.items[index];
                  return Container(
                    margin: EdgeInsets.only(bottom: Demensions.height20),
                    child: Row(
                      children: [
                        Container(
                          height: Demensions.height20 * 4,
                          width: Demensions.width20 * 4,
                          margin: EdgeInsets.only(right: Demensions.width20),
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(Demensions.radius16 / 2),
                            image: DecorationImage(
                              fit: BoxFit.cover,
                              image: NetworkImage(
                                checkoutAdminCtrl
                                    .getAllImage(item.sportFieldId),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              BigText4(text: item.name),
                              SmallText2(text: "Price: \$${item.price}"),
                              SmallText2(text: "Time: ${item.time}"),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                BigText4(text: "Total:"),
                BigText4(text: "\$${totalAmount.toStringAsFixed(2)}"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
