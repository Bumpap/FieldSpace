import 'package:code2/models/demensions.dart';
import 'package:code2/route/route_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../components/sport_field_card.dart';
import '../../controllers/sport_field_ctrl.dart';
import '../../controllers/users_ctrl.dart';
import '../../theme.dart';

class ManageField extends StatelessWidget {
  final String cateid;

  ManageField({required this.cateid});

  @override
  Widget build(BuildContext context) {
    final SportFieldCtrl ctrl = Get.put(SportFieldCtrl());
    final user = Get.find<UsersCtrl>().currentUser.value;

    return WillPopScope(
      onWillPop: () async {
        ctrl.selectedFields.clear();
        return true;
      },
      child: Scaffold(
        backgroundColor: lightBlue100,
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
            'Manage Sport Field',
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
        body: Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  Obx(() {
                    ctrl.fetchDataByCategory(cateid);
                    return ctrl.selectedListByCategory.isEmpty
                        ? noMatchDataView()
                        : Column(
                            children: ctrl.selectedListByCategory
                                .map((fieldEntity) => SportFieldCard(
                                      field: fieldEntity,
                                      isSelected: ctrl.selectedFields
                                          .contains(fieldEntity.id),
                                      onLongPress: (fieldId) {
                                        ctrl.toggleSelection(fieldId);
                                      },
                                    ))
                                .toList(),
                          );
                  }),
                ],
              ),
            ),
            if (user != null && user.role == "admin")
              Positioned(
                bottom: Demensions.height20,
                right: Demensions.width10,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.toNamed(RouteView.getCreateFieldView(cateid));
                      },
                      child: CircleAvatar(
                        radius: Demensions.radius30,
                        backgroundColor: primaryColor500,
                        child: Icon(
                          Icons.add,
                          size: Demensions.Iconsize16 + 18,
                          color: primaryColor300,
                        ),
                      ),
                    ),
                    SizedBox(height: Demensions.height10),
                    GestureDetector(
                      onTap: () {
                        if (ctrl.selectedFields.isNotEmpty) {
                          _showDeleteConfirmationDialog(context, ctrl);
                        }
                      },
                      child: CircleAvatar(
                        radius: Demensions.radius30,
                        backgroundColor: primaryColor500,
                        child: Icon(
                          Icons.remove,
                          size: Demensions.Iconsize16 + 18,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    SizedBox(height: Demensions.height10),
                    GestureDetector(
                      onTap: () {
                        if (ctrl.selectedFields.isNotEmpty) {
                          if (ctrl.selectedFields.length > 1) {
                            Get.snackbar(
                              'Error',
                              'You cannot update more than 1 fields at a time.',
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.toNamed(RouteView.getUpdateFieldView(
                                ctrl.selectedFields.first));
                          }
                        }
                      },
                      child: CircleAvatar(
                        radius: Demensions.radius30,
                        backgroundColor: primaryColor500,
                        child: Icon(
                          Icons.star,
                          size: Demensions.Iconsize16 + 18,
                          color: Colors.yellow,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget noMatchDataView() {
    return Padding(
      padding: EdgeInsets.all(Demensions.radius16),
      child: Column(
        children: [
          Image.asset(
            "assets/images/no_match_data_illustration.png",
            width: Demensions.width20 * 10,
          ),
          SizedBox(height: Demensions.height10 + 6),
          Text(
            "No Match Data.",
            style: titleTextStyle.copyWith(color: darkBlue300),
          ),
          SizedBox(height: Demensions.height10 - 2),
          Text(
            "Sorry we couldn't find what you were looking for, \nplease try create another.",
            style: descTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, SportFieldCtrl ctrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete the selected fields?"),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Delete"),
              onPressed: () {
                ctrl.deleteSelectedFields();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
