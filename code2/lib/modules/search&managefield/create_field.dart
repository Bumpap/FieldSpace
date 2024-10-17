import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../controllers/sport_field_ctrl.dart';
import '../../controllers/users_ctrl.dart';
import '../../models/demensions.dart';
import '../../theme.dart';
import '../../controllers/create_field_ctrl.dart';

class CreateField extends StatelessWidget {
  final String cateid;
  final _formKey = GlobalKey<FormState>();

  CreateField({required this.cateid});

  @override
  Widget build(BuildContext context) {
    final CreateFieldCtrl createFieldCtrl = Get.put(CreateFieldCtrl());
    final SportFieldCtrl sportFieldCtrl = Get.put(SportFieldCtrl());

    createFieldCtrl.cateID.value = cateid;

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
          'Create New Sport Field',
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
      body: Obx(() {
        final user = Get.find<UsersCtrl>().currentUser.value;

        return user == null
            ? Center(
                child: Text(
                  'Please log in to create a new sport field.',
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
                          onChanged: (value) {
                            createFieldCtrl.spname.value = value;
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
                          onChanged: (value) {
                            createFieldCtrl.address.value = value;
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
                          keyboardType: TextInputType.phone,
                          onChanged: (value) {
                            createFieldCtrl.phoneNumber.value = value;
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
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            createFieldCtrl.price.value =
                                int.tryParse(value) ?? 0;
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
                        DropdownButtonFormField<String>(
                          value: createFieldCtrl.openDay.value.isEmpty
                              ? null
                              : createFieldCtrl.openDay.value,
                          decoration: InputDecoration(
                            labelText: 'Open Day',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          items: createFieldCtrl.openDayOptions
                              .map((String option) {
                            return DropdownMenuItem<String>(
                              value: option,
                              child: Text(option),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            createFieldCtrl.openDay.value = newValue ?? '';
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an open day';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: Demensions.height10 + 6),
                        buildTextFormField(
                          labelText: 'Category ID',
                          icon: Icons.category,
                          initialValue: cateid,
                          onChanged: null,
                          enabled: false,
                        ),
                        SizedBox(height: Demensions.height10 + 6),
                        GestureDetector(
                          onTap: () async {
                            await createFieldCtrl.pickImage(context);
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
                                    createFieldCtrl.image.value.isEmpty
                                        ? 'Select Image'
                                        : 'Image Selected',
                                    style:
                                        TextStyle(fontSize: Demensions.font16),
                                  ),
                                ),
                                if (createFieldCtrl.image.value.isNotEmpty)
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
                                    initialTime:
                                        createFieldCtrl.openTime.value != null
                                            ? TimeOfDay.fromDateTime(
                                                createFieldCtrl.openTime.value!
                                                    .toDate())
                                            : TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
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
                                      createFieldCtrl
                                          .updateOpenTime(openDateTime);
                                    }
                                  }
                                },
                                child: Obx(() => Text(
                                      createFieldCtrl
                                              .formattedOpenTime.value.isEmpty
                                          ? 'Select Open Time'
                                          : 'Open Time: ${createFieldCtrl.formattedOpenTime.value}',
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
                                    initialTime:
                                        createFieldCtrl.closeTime.value != null
                                            ? TimeOfDay.fromDateTime(
                                                createFieldCtrl.closeTime.value!
                                                    .toDate())
                                            : TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
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
                                      // If valid, update the close time
                                      DateTime now = DateTime.now();
                                      DateTime closeDateTime = DateTime(
                                        now.year,
                                        now.month,
                                        now.day,
                                        selectedCloseTime.hour,
                                        selectedCloseTime.minute,
                                      );
                                      createFieldCtrl
                                          .updateCloseTime(closeDateTime);
                                    }
                                  }
                                },
                                child: Obx(() => Text(
                                      createFieldCtrl
                                              .formattedCloseTime.value.isEmpty
                                          ? 'Select Close Time'
                                          : 'Close Time: ${createFieldCtrl.formattedCloseTime.value}',
                                    )),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: Demensions.height10 + 6),
                        ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState?.validate() ?? false) {
                              if (createFieldCtrl
                                      .formattedOpenTime.value.isEmpty ||
                                  createFieldCtrl
                                      .formattedCloseTime.value.isEmpty) {
                                Get.snackbar(
                                  'Error',
                                  'Please select both open and close times',
                                  backgroundColor: Colors.red,
                                  colorText: colorWhite,
                                );
                              } else {
                                await createFieldCtrl.createSportField();
                                _formKey.currentState?.reset();
                                sportFieldCtrl.fetchData();
                              }
                            }
                          },
                          child: Text('Create Sport Field'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
      }),
    );
  }

  Widget buildTextFormField({
    required String labelText,
    required IconData icon,
    required Function(String)? onChanged,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    String? initialValue,
    bool enabled = true,
  }) {
    return TextFormField(
      initialValue: initialValue,
      onChanged: onChanged,
      keyboardType: keyboardType,
      validator: validator,
      enabled: enabled,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
      ),
    );
  }
}
