import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/sport_field_ctrl.dart';
import '../theme.dart';

class ExandableDateWidget extends StatefulWidget {
  final String openDay;

  const ExandableDateWidget({
    super.key,
    required this.openDay,
  });

  @override
  State<ExandableDateWidget> createState() => _ExandableDateWidgetState();
}

class _ExandableDateWidgetState extends State<ExandableDateWidget> {
  final TextEditingController _controller = TextEditingController();
  final SportFieldCtrl controller = Get.find();
  DateTime _dateTime = DateTime.now();
  final dateFormat = DateFormat("EEEE, dd MMM yyyy");

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 24, left: 24, bottom: 24, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () {
              _selectDate();
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  border: Border.all(color: primaryColor100, width: 2),
                  color: lightBlue100,
                  borderRadius: BorderRadius.circular(borderRadiusSize)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.date_range_rounded,
                    color: primaryColor500,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    dateFormat.format(_dateTime),
                    style: normalTextStyle,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    DateTime now = DateTime.now();
    DateTime firstDate = now;
    DateTime lastDate = now.add(Duration(days: 365));

    DateTime initialDate = _findValidDate(now, firstDate, lastDate);

    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      selectableDayPredicate: (date) {
        if (widget.openDay.toLowerCase() == 'all day') {
          return true;
        } else {
          int startDayIndex = _getDayIndex(widget.openDay.split(' to ').first);
          int endDayIndex = _getDayIndex(widget.openDay.split(' to ').last);
          int dayIndex = date.weekday;
          return dayIndex >= startDayIndex && dayIndex <= endDayIndex;
        }
      },
    );

    if (selectedDate != null) {
      setState(() {
        _dateTime = selectedDate;
        controller.selectedDate.value =
            DateFormat('EEEE, dd MMM yyyy').format(_dateTime);
      });
    }
  }

  DateTime _findValidDate(
      DateTime currentDate, DateTime firstDate, DateTime lastDate) {
    while (currentDate.isBefore(lastDate)) {
      if (_isSelectable(currentDate)) {
        return currentDate;
      }
      currentDate = currentDate.add(Duration(days: 1));
    }

    return firstDate;
  }

  bool _isSelectable(DateTime date) {
    if (widget.openDay.toLowerCase() == 'all day') {
      return true;
    } else {
      int startDayIndex = _getDayIndex(widget.openDay.split(' to ').first);
      int endDayIndex = _getDayIndex(widget.openDay.split(' to ').last);
      int dayIndex = date.weekday;
      return dayIndex >= startDayIndex && dayIndex <= endDayIndex;
    }
  }

  int _getDayIndex(String day) {
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
}
