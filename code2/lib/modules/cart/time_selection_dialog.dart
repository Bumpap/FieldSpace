import 'package:code2/controllers/cart_field_ctrl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/sport_field_ctrl.dart';
import '../../models/radiobox_state.dart';
import '../../utils/dummy_data.dart';

class TimeSelectionDialog extends StatefulWidget {
  final String bookedTimes;
  final Function(String) onTimeSelected;
  final bool isBooked1;
  final String sport_id;
  final String? bookedTimes1;

  const TimeSelectionDialog({
    super.key,
    required this.bookedTimes,
    required this.onTimeSelected,
    required this.isBooked1,
    required this.sport_id,
    required this.bookedTimes1,
  });

  @override
  _TimeSelectionDialogState createState() => _TimeSelectionDialogState();
}

class _TimeSelectionDialogState extends State<TimeSelectionDialog> {
  var availableTimes = <RadioBoxState>[];
  String? selectedTime;
  final List<String> timeList = timeToBook;
  int interval = 1;
  final SportFieldCtrl controller = Get.find();
  final CartFieldCtrl cartFieldCtrl = Get.find();
  var currentTime = "00.00";

  @override
  void initState() {
    super.initState();
    fetchTimesAndUpdateAvailableTimes();
  }

  void fetchTimesAndUpdateAvailableTimes() async {
    await controller.fetchAndUpdateTimes(widget.sport_id);
    updateAvailableTimes(interval);
    setState(() {});
  }

  Future<void> updateAvailableTimes(int interval) async {
    availableTimes.clear();

    String openTime =
        DateFormat('HH.mm').format(controller.openTime.value.toDate());
    String closeTime =
        DateFormat('HH.mm').format(controller.closeTime.value.toDate());

    currentTime = openTime;

    List<List<String>> bookedTimesList = widget.bookedTimes
        .split(',')
        .map((e) => e.split('-').map((e) => e.trim()).toList())
        .toList();

    bookedTimesList =
        bookedTimesList.where((pair) => pair.length == 2).toList();

    if (bookedTimesList.isNotEmpty) {
      String startTime = bookedTimesList.first[0];
      String endTime = bookedTimesList.first[1];

      if (timeList.indexOf(endTime) - timeList.indexOf(startTime) > interval) {
        interval = timeList.indexOf(endTime) - timeList.indexOf(startTime);
      }

      for (int i = timeList.indexOf(currentTime);
          i < timeList.length - interval;
          i += interval) {
        if (currentTime == closeTime) {
          break;
        } else {
          String startTimeStr = timeList[i];
          String endTimeStr = timeList[i + interval];
          String timeRange = "$startTimeStr - $endTimeStr";

          bool isBooked = false;
          if (widget.isBooked1) {
            isBooked = bookedTimesList.any(
              (bookedTime) => (bookedTime[0] == startTimeStr ||
                  bookedTime[1] == endTimeStr),
            );
          } else {
            if (widget.bookedTimes1 != null) {
              List<List<String>> bookedTimesList1 = widget.bookedTimes1!
                  .split(',')
                  .map((e) => e.split('-').map((e) => e.trim()).toList())
                  .toList();
              bookedTimesList1 =
                  bookedTimesList1.where((pair) => pair.length == 2).toList();

              isBooked = bookedTimesList1.any(
                (bookedTime) => (bookedTime[0] == startTimeStr ||
                    bookedTime[1] == endTimeStr),
              );
            }
          }

          if (!isBooked) {
            availableTimes.add(RadioBoxState(title: timeRange));
          }
          currentTime = timeList[i + interval];
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      updateAvailableTimes(interval);
    });

    return AlertDialog(
      title: Text("Select Time Slot"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: availableTimes.map((time) {
            return RadioListTile<String>(
              title: Text(time.title),
              value: time.title,
              groupValue: selectedTime,
              onChanged: (String? value) {
                setState(() {
                  selectedTime = value;
                  widget.onTimeSelected(selectedTime!);
                  Navigator.pop(context);
                });
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("Cancel"),
        ),
      ],
    );
  }
}
