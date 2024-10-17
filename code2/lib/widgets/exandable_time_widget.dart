import 'package:code2/controllers/cart_field_ctrl.dart';
import 'package:code2/models/demensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/sport_field_ctrl.dart';
import '../models/radiobox_state.dart';
import '../utils/dummy_data.dart';

class ExandableTimeWidget extends StatefulWidget {
  final String id;
  final Future<String?> userID;

  const ExandableTimeWidget({super.key, required this.id, required this.userID});

  @override
  State<ExandableTimeWidget> createState() => _ExandableTimeWidgetState();
}

class _ExandableTimeWidgetState extends State<ExandableTimeWidget> {
  final SportFieldCtrl controller = Get.find();
  final CartFieldCtrl cartFieldCtrl = Get.find();
  var availableBookTime = <RadioBoxState>[];
  List<String> timeList = timeToBook;
  var currentTime = "00.00";
  String? selectedTime;

  // Future<String?> getUserID() async {
  //   return await cartFieldCtrl.getUserIDBySportId(widget.id);
  // }

  Future<void> updateAvailableBookTime(int interval) async {
    availableBookTime.clear();

    String? userID = await widget.userID;
    print("userID: ${userID}");
    String? currentUserID = FirebaseAuth.instance.currentUser?.uid;


    String openTime =
        DateFormat('HH.mm').format(controller.openTime.value.toDate());
    String closeTime =
        DateFormat('HH.mm').format(controller.closeTime.value.toDate());

    currentTime = openTime;

    List<Map<String, String>> bookedTimesWithDate =
        await cartFieldCtrl.getBookedTimesWithDate(widget.id);

    String selectedDate = controller.selectedDate.value;
    List<String> bookedTimes = bookedTimesWithDate
        .where((booking) => booking['date'] == selectedDate)
        .map((booking) => booking['time']!)
        .toList();

    for (int i = timeList.indexOf(currentTime);
        i < timeList.length - interval;
        i += interval) {
      if (currentTime == closeTime) {
        break;
      } else {
        String startTime = timeList[i];
        String endTime = timeList[i + interval];
        String timeRange = "$startTime - $endTime";

        bool isBooked = false;
        for (String bookedTime in bookedTimes) {
          String bookedStart = bookedTime.split(" - ")[0];
          String bookedEnd = bookedTime.split(" - ")[1];

          if ((startTime.compareTo(bookedStart) >= 0 &&
                  startTime.compareTo(bookedEnd) < 0) ||
              (endTime.compareTo(bookedStart) > 0 &&
                  endTime.compareTo(bookedEnd) <= 0) ||
              (startTime.compareTo(bookedStart) <= 0 &&
                  endTime.compareTo(bookedEnd) >= 0)) {
            isBooked = true;
            break;
          }
        }

        if(!isBooked){
          availableBookTime.add(RadioBoxState(title: timeRange));
        } else {
          if(userID == currentUserID) {
            if (interval == 1 || interval == 2) {
              i += interval;
            }
            else {
              i = i;
            }
          }
        }

        currentTime = timeList[i + interval];
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    int interval = controller.quality;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateAvailableBookTime(interval);
      cartFieldCtrl.fetchData();
    });

    return Padding(
      padding: EdgeInsets.only(
        right: Demensions.width20 + 4,
        left: Demensions.width20 + 4,
        bottom: Demensions.height20 + 4,
        top: Demensions.height10 - 2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...availableBookTime.map(buildSingleRadioBox).toList(),
        ],
      ),
    );
  }

  Widget buildSingleRadioBox(RadioBoxState radioBox) {
    return RadioListTile<String>(
      controlAffinity: ListTileControlAffinity.leading,
      title: Text(radioBox.title),
      value: radioBox.title,
      groupValue: selectedTime,
      onChanged: (String? value) {
        setState(() {
          selectedTime = value!;
          controller.selectedTime.value = value;
        });
      },
    );
  }
}
