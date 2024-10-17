import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/users_ctrl.dart';
import '../../models/demensions.dart';
import '../../theme.dart';
import '../../controllers/sport_field_ctrl.dart';

class UpdateField extends StatelessWidget {
  final String id;
  final _formKey = GlobalKey<FormState>();

  UpdateField({required this.id});

  @override
  Widget build(BuildContext context) {
    final SportFieldCtrl ctrl = Get.find();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.fetchFieldById(id);
    });

    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: primaryColor500,
          statusBarIconBrightness: Brightness.light,
        ),
        toolbarHeight: Demensions.height10 * 5,
        backgroundColor: primaryColor500,
        centerTitle: true,
        title: Text(
          'Update Sport Field',
          style: TextStyle(
            color: Colors.white,
            fontSize: Demensions.font26,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      body: FutureBuilder<void>(
        future: ctrl.fetchFieldById(id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading sport field data.',
                style: TextStyle(
                    fontSize: Demensions.font16 + 2, color: Colors.red),
              ),
            );
          }

          final user = Get.find<UsersCtrl>().currentUser.value;
          return user == null
              ? Center(
                  child: Text(
                    'Please log in to update the sport field.',
                    style: TextStyle(
                        fontSize: Demensions.font16 + 2, color: Colors.red),
                  ),
                )
              : SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.all(borderRadiusSize1),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          buildTextFormField(
                            labelText: 'Sport Field Name',
                            icon: Icons.sports_baseball,
                            initialValue: ctrl.spname.value,
                            onChanged: (value) {
                              ctrl.spname.value = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a sport field name';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          buildTextFormField(
                            labelText: 'Address',
                            icon: Icons.location_on,
                            initialValue: ctrl.address.value,
                            onChanged: (value) {
                              ctrl.address.value = value;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter an address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          buildTextFormField(
                            labelText: 'Phone Number',
                            icon: Icons.phone,
                            initialValue: ctrl.phoneNumber.value,
                            keyboardType: TextInputType.phone,
                            onChanged: (value) {
                              ctrl.phoneNumber.value = (value);
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a phone number';
                              }
                              if (!GetUtils.isPhoneNumber(value)) {
                                return 'Please enter a valid phone number';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          buildTextFormField(
                            labelText: 'Price',
                            icon: Icons.attach_money,
                            initialValue: ctrl.price.value.toString(),
                            keyboardType: TextInputType.number,
                            onChanged: (value) {
                              ctrl.price.value = int.tryParse(value) ?? 0;
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a price';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Please enter a valid price';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          buildTextFormField(
                            labelText: 'Category ID',
                            icon: Icons.category,
                            initialValue: ctrl.cateID.value,
                            keyboardType: TextInputType.number,
                            onChanged: null,
                            // Make it non-editable,
                            enabled: false,
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          DropdownButtonFormField<String>(
                            value: ctrl.openDay.value.isEmpty
                                ? null
                                : ctrl.openDay.value,
                            decoration: InputDecoration(
                              labelText: 'Open Day',
                              prefixIcon: Icon(Icons.calendar_today),
                              border: OutlineInputBorder(),
                            ),
                            items: ctrl.openDayOptions.map((String option) {
                              return DropdownMenuItem<String>(
                                value: option,
                                child: Text(option),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              ctrl.openDay.value = newValue ?? '';
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an open day';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          GestureDetector(
                            onTap: () async {
                              await ctrl.pickImage(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12.0),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.3),
                                    spreadRadius: 2,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              padding: EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  Icon(Icons.image, color: primaryColor500),
                                  SizedBox(width: Demensions.height10),
                                  Expanded(
                                    child: Text(
                                      ctrl.image.value.isEmpty
                                          ? 'Select Image'
                                          : 'Image Selected',
                                      style: TextStyle(
                                          fontSize: Demensions.font16),
                                    ),
                                  ),
                                  if (ctrl.image.value.isNotEmpty)
                                    Icon(Icons.check, color: Colors.green),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    TimeOfDay? selectedOpenTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          ctrl.openTime.value.toDate()),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        // Customizing the time picker to show only times from 6:00 AM onwards
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true,
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (selectedOpenTime != null) {
                                      if (selectedOpenTime.minute != 0 ||
                                          (selectedOpenTime.hour >= 0 &&
                                              selectedOpenTime.hour < 6)) {
                                        Get.snackbar(
                                          'Invalid Time',
                                          'Please select a time starting from 6:00 AM to 11:00 PM with 00 minutes.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        DateTime now = DateTime.now();
                                        DateTime openDateTime = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          selectedOpenTime.hour,
                                          selectedOpenTime.minute,
                                        );
                                        ctrl.updateOpenTime(openDateTime);
                                      }
                                    }
                                  },
                                  child: Obx(() => Text(
                                        ctrl.formattedOpenTime.value.isEmpty
                                            ? 'Select Open Time'
                                            : 'Open Time: ${ctrl.formattedOpenTime.value}',
                                      )),
                                ),
                              ),
                              SizedBox(width: Demensions.height10 + 6),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () async {
                                    TimeOfDay? selectedCloseTime =
                                        await showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.fromDateTime(
                                          ctrl.closeTime.value.toDate()),
                                      builder: (BuildContext context,
                                          Widget? child) {
                                        return MediaQuery(
                                          data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true,
                                          ),
                                          child: child!,
                                        );
                                      },
                                    );

                                    if (selectedCloseTime != null) {
                                      if ((selectedCloseTime.hour >= 0 &&
                                              selectedCloseTime.hour < 6) ||
                                          selectedCloseTime.minute != 0) {
                                        Get.snackbar(
                                          'Invalid Time',
                                          'Please select a time starting from 6:00 AM to 11:00 PM with 00 minutes.',
                                          backgroundColor: Colors.red,
                                          colorText: Colors.white,
                                        );
                                      } else {
                                        DateTime now = DateTime.now();
                                        DateTime closeDateTime = DateTime(
                                          now.year,
                                          now.month,
                                          now.day,
                                          selectedCloseTime.hour,
                                          selectedCloseTime.minute,
                                        );
                                        ctrl.updateCloseTime(closeDateTime);
                                      }
                                    }
                                  },
                                  child: Obx(() => Text(
                                        ctrl.formattedCloseTime.value.isEmpty
                                            ? 'Select Close Time'
                                            : 'Close Time: ${ctrl.formattedCloseTime.value}',
                                      )),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: Demensions.height10 + 6),
                          ElevatedButton(
                            onPressed: () async {
                              if (ctrl.openTime.value
                                  .toDate()
                                  .isAfter(ctrl.closeTime.value.toDate())) {
                                Get.snackbar(
                                  'Error',
                                  'Open time must be earlier than close time',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else if (ctrl.openTime.value
                                  .toDate()
                                  .isAtSameMomentAs(
                                      ctrl.closeTime.value.toDate())) {
                                Get.snackbar(
                                  'Error',
                                  'Open time must be same close time',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              } else {
                                await ctrl.updateFieldData(id);
                                Get.back();
                              }
                            },
                            child: Text('Update Sport Field'),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
        },
      ),
    );
  }

  Widget buildTextFormField({
    required String labelText,
    required IconData icon,
    required String initialValue,
    required Function(String)? onChanged,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
  }) {
    return TextFormField(
      keyboardType: keyboardType,
      initialValue: initialValue,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
      onChanged: onChanged,
      validator: validator,
      enabled: enabled,
    );
  }
}
