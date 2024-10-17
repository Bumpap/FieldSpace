import 'package:code2/components/empty_data_view.dart';
import 'package:code2/modules/cart/time_selection_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:intl/intl.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import '../../controllers/cart_field_ctrl.dart';
import '../../models/demensions.dart';
import '../../theme.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/big_text.dart';
import '../../widgets/big_text4.dart';
import '../../widgets/big_text5.dart';
import '../../widgets/small_text.dart';
import '../../route/route_view.dart';

class CartView extends StatelessWidget {
  const CartView({super.key});

  // Future<void> sendReminderEmail(User? user, dynamic item) async {
  //   final smtpServer = gmail('luuthithi07@gmail.com', 'elzfblyctnlyqcfk');
  //   final message = Message()
  //     ..from = const Address('luuthithi07@gmail.com', 'Admin')
  //     ..recipients.add(user?.email ?? '')
  //     ..subject = 'Booking Reminder'
  //     ..text =
  //         'Reminder: Please pay for ${item.spname} by PayPal or come to ${item.spname} and pay in cash 15 minutes in advance. Otherwise we will cancel your schedule';
  //
  //   try {
  //     final sendReport = await send(message, smtpServer);
  //     print('Message sent: ${sendReport.mail}');
  //   } on MailerException catch (e) {
  //     print('Message not sent. ${e.toString()}');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    final CartFieldCtrl cartFieldCtrl = Get.find();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      cartFieldCtrl.fetchData();
    });

    // cartFieldCtrl.fetchData();

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: Demensions.height20 * 3,
            left: Demensions.width20,
            right: Demensions.width20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Get.back();
                  },
                  child: AppIcon(
                    icon: Icons.arrow_back_ios,
                    iconColor: Colors.white,
                    backgroundColor: primaryColor500,
                    size: Demensions.height45,
                  ),
                ),
                SizedBox(
                  width: Demensions.width20 * 5,
                ),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(RouteView.getHome());
                  },
                  child: AppIcon(
                    icon: Icons.home_outlined,
                    iconColor: Colors.white,
                    backgroundColor: primaryColor500,
                    size: Demensions.height45,
                  ),
                ),
              ],
            ),
          ),
          GetBuilder<CartFieldCtrl>(builder: (_cartCtrl) {
            return _cartCtrl.items.length > 0
                ? Positioned(
                    top: Demensions.height20 * 5.5,
                    left: Demensions.width20,
                    right: Demensions.width20,
                    bottom: 0,
                    child: Obx(() {
                      if (cartFieldCtrl.isLoading) {
                        return Center(child: CircularProgressIndicator());
                      }
                      // Set<String> sentReminderEmails = {};

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: cartFieldCtrl.items.length,
                              itemBuilder: (_, index) {
                                var item = cartFieldCtrl.items[index];
                                // User? user = FirebaseAuth.instance.currentUser;

                                List<String> timeRange = item.Time.split(' - ');
                                DateTime now = DateTime.now();
                                DateFormat timeFormat = DateFormat("H.mm");
                                DateTime startTime =
                                    timeFormat.parse(timeRange[0]);
                                startTime = DateTime(now.year, now.month,
                                    now.day, startTime.hour, startTime.minute);
                                DateTime endTime =
                                    timeFormat.parse(timeRange[1]);
                                endTime = DateTime(now.year, now.month, now.day,
                                    endTime.hour, endTime.minute);

                                // if (!sentReminderEmails.contains(item.id) &&
                                //     now.isAfter(startTime
                                //         .subtract(Duration(minutes: 30))) &&
                                //     now.isBefore(startTime)) {
                                //   sendReminderEmail(user, item);
                                //   sentReminderEmails.add(item.id);
                                // }

                                bool isWithin15Minutes = now.isAfter(startTime
                                        .subtract(Duration(minutes: 15))) &&
                                    now.isBefore(endTime);

                                if (isWithin15Minutes) {
                                  cartFieldCtrl.removeItemCart(item.id);
                                  return Container();
                                }

                                return Container(
                                  width: double.maxFinite,
                                  padding: EdgeInsets.only(
                                      bottom: Demensions.height10),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: Demensions.height20 * 5,
                                        height: Demensions.height20 * 5,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            fit: BoxFit.cover,
                                            image: NetworkImage(cartFieldCtrl
                                                .getImage(item.sport_id)),
                                          ),
                                          borderRadius: BorderRadius.circular(
                                              Demensions.radius20),
                                          color: Colors.white,
                                        ),
                                      ),
                                      SizedBox(
                                        width: Demensions.width10,
                                      ),
                                      Expanded(
                                        child: Container(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  BigText(text: item.spname),
                                                  GestureDetector(
                                                    onTap: () {
                                                      cartFieldCtrl
                                                          .removeItemCart(
                                                              item.id);
                                                    },
                                                    child: AppIcon(
                                                      icon: Icons.close,
                                                      iconColor: Colors.white,
                                                      backgroundColor:
                                                          primaryColor500,
                                                      size: Demensions.height45,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SmallText(
                                                  text:
                                                      cartFieldCtrl.getAddress(
                                                          item.sport_id)),
                                              SmallText(text: item.DatePick),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  BigText5(
                                                      text: "${item.price}"),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      String bookedTimes =
                                                          await cartFieldCtrl
                                                              .getBookedTimesByDocIdAndSportFieldId(
                                                                  item.id,
                                                                  item.sport_id);
                                                      String? bookedTimes1 =
                                                          await cartFieldCtrl
                                                              .getStringBookedTimesBySportFieldId(
                                                                  item.sport_id,
                                                                  item.DatePick);
                                                      showDialog(
                                                        context: context,
                                                        builder: (_) =>
                                                            TimeSelectionDialog(
                                                          bookedTimes:
                                                              bookedTimes,
                                                          onTimeSelected:
                                                              (selectedTime) {
                                                            cartFieldCtrl
                                                                .updateBookingTime(
                                                                    item.id,
                                                                    selectedTime);
                                                          },
                                                          isBooked1:
                                                              item.isBook,
                                                          sport_id:
                                                              item.sport_id,
                                                          bookedTimes1:
                                                              bookedTimes1,
                                                        ),
                                                      );
                                                    },
                                                    child: Container(
                                                      padding: EdgeInsets.all(
                                                          Demensions.height5),
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                                Demensions
                                                                    .radius20),
                                                        color: Colors.white,
                                                        border: Border.all(
                                                            color:
                                                                primaryColor500),
                                                      ),
                                                      child: Row(
                                                        children: [
                                                          Icon(
                                                              Icons.access_time,
                                                              color:
                                                                  primaryColor500),
                                                          SizedBox(
                                                              width: Demensions
                                                                  .width10),
                                                          Text(
                                                            item.isBook
                                                                ? item.Time
                                                                : "Select Time",
                                                            style: TextStyle(
                                                                color:
                                                                    primaryColor500),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    }))
                : EmptyDataView(
                    text: "Your Cart Is Empty",
                    imgEmpty: "assets/images/no_match_data_illustration.png");
          })
        ],
      ),
      bottomNavigationBar: Container(
        height: Demensions.bottomHeightBar,
        padding: EdgeInsets.only(
            top: Demensions.height30,
            bottom: Demensions.height30,
            left: Demensions.width20,
            right: Demensions.width20),
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
            Container(
              padding: EdgeInsets.only(
                  top: Demensions.height20,
                  bottom: Demensions.height20,
                  left: Demensions.width20,
                  right: Demensions.width20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Demensions.radius20),
                color: Colors.white,
              ),
              child: Row(
                children: [
                  SizedBox(width: Demensions.width10 / 2),
                  Obx(() =>
                      BigText4(text: "\$${cartFieldCtrl.getTotalPrice()}")),
                  SizedBox(width: Demensions.width10 / 2),
                ],
              ),
            ),
            GestureDetector(
              onTap: () async {
                User? user = FirebaseAuth.instance.currentUser;
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Select Payment Method"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Image.asset("assets/images/paypal.png"),
                            title: Text("PayPal"),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) => UsePaypal(
                                      sandboxMode: true,
                                      clientId:
                                          "AUjvkKwYrA6HskxazImf31De0OWxwtRogcR7FOErdW34c_LvTSaujdXGi6ue3ICqRaT-8Bc90yrE-Ljm",
                                      secretKey:
                                          "EDlHw5UBZuqCvb9zp2Fv91vXWAtZSG7UJyxygg2XcvnVss5xsQzU8HVenOVI5Goke2M70o7pT47ryJTo",
                                      returnURL:
                                          "https://samplesite.com/return",
                                      cancelURL:
                                          "https://samplesite.com/cancel",
                                      transactions: [
                                        {
                                          "amount": {
                                            "total": cartFieldCtrl
                                                .getTotalPrice()
                                                .toStringAsFixed(2),
                                            "currency": "USD",
                                            "details": {
                                              "subtotal": cartFieldCtrl
                                                  .getTotalPrice()
                                                  .toStringAsFixed(2),
                                              "shipping": '0',
                                              "shipping_discount": 0
                                            }
                                          },
                                          "description":
                                              "Payment for sports field booking.",
                                          "item_list": {
                                            "items":
                                                cartFieldCtrl.items.map((item) {
                                              return {
                                                "name": item.spname,
                                                "quantity": 1,
                                                "price": item.price
                                                    .toStringAsFixed(2),
                                                "currency": "USD"
                                              };
                                            }).toList(),
                                          }
                                        }
                                      ],
                                      note:
                                          "Thank you for your booking. Contact us for any questions.",
                                      onSuccess: (Map params) async {
                                        await cartFieldCtrl.checkout(user!.uid);
                                        print("onSuccess: $params");
                                      },
                                      onError: (error) {
                                        print("onError: $error");
                                      },
                                      onCancel: (params) {
                                        print('cancelled: $params');
                                      }),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: Image.asset("assets/images/wallet.png"),
                            title: Text("Cash"),
                            onTap: () async {
                              Navigator.pop(context);
                              await cartFieldCtrl.checkout(user!.uid);
                            },
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              child: Container(
                padding: EdgeInsets.only(
                    top: Demensions.height20,
                    bottom: Demensions.height20,
                    left: Demensions.width20,
                    right: Demensions.width20),
                child: BigText4(text: "Checkout"),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(Demensions.radius20),
                  color: primaryColor500,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
