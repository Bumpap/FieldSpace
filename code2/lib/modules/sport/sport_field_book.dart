import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../controllers/sport_field_ctrl.dart';
import '../../controllers/cart_field_ctrl.dart';
import '../../data/repos/cart_field_repo.dart';
import '../../data/api/api_cart_field.dart';
import '../../route/route_view.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/big_text1.dart';
import '../../widgets/big_text4.dart';
import '../../widgets/exandable_date_widget.dart';
import '../../widgets/exandable_time_widget.dart';
import '../../theme.dart';
import 'package:code2/models/demensions.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server.dart';

class SportFieldBook extends StatelessWidget {
  final String id;

  const SportFieldBook({super.key, required this.id});



  @override
  Widget build(BuildContext context) {
    final SportFieldCtrl controller = Get.find();
    final CartFieldCtrl cartFieldController = Get.find();
    final ApiCartField apiCartField = Get.find();
    User? user = FirebaseAuth.instance.currentUser;

    Future<String?> userID = cartFieldController.getUserIDBySportId(id);

    controller.fetchFieldById(id);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        return Stack(
          children: [
            // Image
            Positioned(
              left: 0,
              right: 0,
              child: Container(
                width: double.maxFinite,
                height: Demensions.popularSportImgSize,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(controller.image.value),
                  ),
                ),
              ),
            ),
            // Icon
            Positioned(
              top: Demensions.height45,
              left: Demensions.width20,
              right: Demensions.width20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: AppIcon(icon: Icons.arrow_back_ios),
                  ),
                  StreamBuilder<int>(
                    stream:
                        apiCartField.getBookingCountStream(id, user?.uid ?? ''),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting ||
                          user == null) {
                        return AppIcon(icon: Icons.bookmark_add);
                      }
                      if (snapshot.hasError) {
                        return AppIcon(icon: Icons.bookmark_add);
                      }
                      final count = snapshot.data ?? 0;
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Get.toNamed(RouteView.getCartView());
                            },
                            child: AppIcon(icon: Icons.bookmark_add),
                          ),
                          if (count > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: Demensions.width20,
                                  maxHeight: Demensions.height20,
                                ),
                                child: Center(
                                  child: Text(
                                    count.toString(),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            // Time
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: Demensions.popularSportImgSize - 20,
              child: Container(
                padding: EdgeInsets.only(
                    left: Demensions.width20,
                    right: Demensions.width20,
                    top: Demensions.height20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(Demensions.radius20),
                    topLeft: Radius.circular(Demensions.radius20),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          BigText1(text: "Pick a date"),
                          ExandableDateWidget(
                            openDay: controller.openDay.value,
                          ),
                          BigText4(text: "Pick a time"),
                          ExandableTimeWidget(id: id, userID: userID,),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
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
                  GestureDetector(
                    onTap: () {
                      controller.setQuantity(false);
                    },
                    child: Icon(Icons.remove, color: Colors.black),
                  ),
                  SizedBox(width: Demensions.width10 / 2),
                  Obx(() => BigText4(text: controller.quality.toString())),
                  SizedBox(width: Demensions.width10 / 2),
                  GestureDetector(
                    onTap: () {
                      controller.setQuantity(true);
                    },
                    child: Icon(Icons.add, color: Colors.black),
                  ),
                ],
              ),
            ),
            Obx(() {
              final totalPrice = controller.price.value * controller.quality;
              return GestureDetector(
                onTap: () async {
                  final selectedTime = controller.selectedTime.value;
                  if (selectedTime.isEmpty) {
                    Get.snackbar("Booking Error", "Please select a time slot.",
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  final selectedDate = controller.selectedDate.value;
                  if (selectedDate.isEmpty) {
                    Get.snackbar("Booking Error", "Please select a date.",
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  try {
                    List<String> timeRange = selectedTime.split(' - ');
                    DateTime now = DateTime.now();
                    DateFormat timeFormat = DateFormat("H.mm");
                    DateTime startTime = timeFormat.parse(timeRange[0]);
                    startTime = DateTime(now.year, now.month, now.day,
                        startTime.hour, startTime.minute);
                    DateTime endTime = timeFormat.parse(timeRange[1]);
                    endTime = DateTime(now.year, now.month, now.day,
                        endTime.hour, endTime.minute);


                    if (startTime.isBefore(now.add(Duration(minutes: 15))) ||
                        endTime.isBefore(now.add(Duration(minutes: 15)))) {
                      Get.snackbar("Booking Error",
                          "The selected time is within 15 minutes from now. Please select a different time.",
                          backgroundColor: Colors.red, colorText: Colors.white);
                      return;
                    }
                  } catch (error) {
                    Get.snackbar(
                        "Booking Error", "Failed to parse time: $error",
                        backgroundColor: Colors.red, colorText: Colors.white);
                    return;
                  }

                  if (user == null) {
                    Get.toNamed(RouteView.getSignInView());
                    return;
                  }

                  final newBooking = CartFieldRepo(
                    id: '',
                    spname: controller.spname.value,
                    image: controller.image.value,
                    price: totalPrice,
                    sport_id: id,
                    Time: selectedTime,
                    isBook: true,
                    userID: user.uid,
                    DatePick: selectedDate,
                  );
                  cartFieldController.addBooking(newBooking);

                  final smtpServer =
                      gmail('luuthithi07@gmail.com', 'elzfblyctnlyqcfk');
                  final message = Message()
                    ..from = const Address('luuthithi07@gmail.com', 'Admin')
                    ..recipients.add(user.email ?? '')
                    ..subject = 'Booking Confirmation'
                    ..text =
                        'You have booked a sport field!\n\nDate: $selectedDate\nTime: $selectedTime\n'
                        'Reminder: Please pay for ${controller.spname.value} by PayPal or come to ${controller.spname.value} and pay in cash 15 minutes in advance. Otherwise we will cancel your schedule\n\nThank you for using our service.';

                  try {
                    final sendReport = await send(message, smtpServer);
                    Get.snackbar("Booking Success",
                        "Your booking has been confirmed and an email has been sent.",
                        backgroundColor: Colors.green, colorText: Colors.white);
                    print('Message sent: ${sendReport.mail}');
                  } catch (error) {
                    Get.snackbar(
                        "Booking Error", "Failed to send email: $error",
                        backgroundColor: Colors.red, colorText: Colors.white);
                    print("Error Email: ${error}");
                  }
                },
//                 onTap: () async {
//                   final selectedDate = controller.selectedDate.value;
//                   final selectedTime = controller.selectedTime.value;
//
//                   if (selectedTime.isEmpty) {
//                     Get.snackbar("Booking Error", "Please select a time slot.",
//                         backgroundColor: Colors.red, colorText: Colors.white);
//                     return;
//                   }
//
//                   if (selectedDate.isEmpty) {
//                     Get.snackbar("Booking Error", "Please select a date.",
//                         backgroundColor: Colors.red, colorText: Colors.white);
//                     return;
//                   }
//
//                   try {
//                     List<String> timeRange = selectedTime.split(' - ');
//                     DateTime now = DateTime.now();
//                     DateFormat timeFormat = DateFormat("H.mm");
//                     DateTime startTime = timeFormat.parse(timeRange[0]);
//                     DateTime endTime = timeFormat.parse(timeRange[1]);
//
//                     // Parse the selectedDate to DateTime
//                     DateFormat dateFormat = DateFormat('EEEE, dd MMM yyyy');
//                     DateTime selectedDateTime = dateFormat.parse(selectedDate);
//                     print("selectedDateTime: ${selectedDateTime}");
//
//                     // Combine the selectedDate with the time to get full DateTime
//                     startTime = DateTime(selectedDateTime.year, selectedDateTime.month,
//                         selectedDateTime.day, startTime.hour, startTime.minute);
//                     endTime = DateTime(selectedDateTime.year, selectedDateTime.month,
//                         selectedDateTime.day, endTime.hour, endTime.minute);
//
//                     // Check if the selected date is today
//                     if (selectedDateTime.isAtSameMomentAs(now)) {
//                       // If the selected date is today, check if the times are within 15 minutes from now
//                       if (startTime.isBefore(now.add(Duration(minutes: 15))) ||
//                           endTime.isBefore(now.add(Duration(minutes: 15)))) {
//                         Get.snackbar("Booking Error",
//                             "The selected time is within 15 minutes from now or Time booked before current time. Please select a different time.",
//                             backgroundColor: Colors.red, colorText: Colors.white);
//                         return;
//                       }
//                     } else {
//                       // If the selected date is not today, check if the times are in the past
//                       if (startTime.isBefore(now) || endTime.isBefore(now)) {
//                         Get.snackbar("Booking Error",
//                             "The selected time is in the past. Please select a future time.",
//                             backgroundColor: Colors.red, colorText: Colors.white);
//                         return;
//                       }
//                     }
//                   } catch (error) {
//                     Get.snackbar(
//                         "Booking Error", "Failed to parse time or date: $error",
//                         backgroundColor: Colors.red, colorText: Colors.white);
//                     return;
//                   }
//
// // Continue with booking process if validation passes
//
//                   if (user == null) {
//                     Get.toNamed(RouteView.getSignInView());
//                     return;
//                   }
//
//                   final newBooking = CartFieldRepo(
//                     id: '',
//                     spname: controller.spname.value,
//                     image: controller.image.value,
//                     price: totalPrice,
//                     sport_id: id,
//                     Time: selectedTime,
//                     isBook: true,
//                     userID: user.uid,
//                     DatePick: selectedDate,
//                   );
//                   cartFieldController.addBooking(newBooking);
//
//                   final smtpServer = gmail('luuthithi07@gmail.com', 'elzfblyctnlyqcfk');
//                   final message = Message()
//                     ..from = const Address('luuthithi07@gmail.com', 'Admin')
//                     ..recipients.add(user.email ?? '')
//                     ..subject = 'Booking Confirmation'
//                     ..text =
//                         'You have booked a sport field!\n\nDate: $selectedDate\nTime: $selectedTime\n'
//                         'Reminder: Please pay for ${controller.spname.value} by PayPal or come to ${controller.spname.value} and pay in cash 15 minutes in advance. Otherwise we will cancel your schedule\n\nThank you for using our service.';
//
//                   try {
//                     final sendReport = await send(message, smtpServer);
//                     Get.snackbar("Booking Success",
//                         "Your booking has been confirmed and an email has been sent.",
//                         backgroundColor: Colors.green, colorText: Colors.white);
//                     print('Message sent: ${sendReport.mail}');
//                   } catch (error) {
//                     Get.snackbar("Booking Error", "Failed to send email: $error",
//                         backgroundColor: Colors.red, colorText: Colors.white);
//                     print("Error Email: ${error}");
//                   }
//                 },
                child: Container(
                  padding: EdgeInsets.only(
                      top: Demensions.height20,
                      bottom: Demensions.height20,
                      left: Demensions.width20,
                      right: Demensions.width20),
                  child: BigText4(
                      text: "\$${totalPrice.toStringAsFixed(0)} | Book"),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Demensions.radius20),
                    color: primaryColor200,
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
