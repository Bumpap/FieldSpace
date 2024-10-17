import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../components/sport_field_card.dart';
import '../../controllers/search_view_ctrl.dart';
import '../../models/demensions.dart';
import '../../theme.dart';

class SearchView extends StatelessWidget {
  final String selectedDropdownItem;

  SearchView({required this.selectedDropdownItem});

  @override
  Widget build(BuildContext context) {
    final SearchViewController ctrl = Get.put(SearchViewController());

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ctrl.selectedDropdownItem = selectedDropdownItem;
    });

    return Scaffold(
      backgroundColor: lightBlue100,
      appBar: AppBar(
        elevation: 0.0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: primaryColor500,
          statusBarIconBrightness: Brightness.light,
        ),
        toolbarHeight: 0,
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.only(
                  top: Demensions.height10 - 2,
                  left: Demensions.width10 + 6,
                  right: Demensions.height10 + 6,
                  bottom: Demensions.height10 - 2),
              color: primaryColor500,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    icon: const Icon(CupertinoIcons.arrow_left),
                    color: colorWhite,
                  ),
                  Obx(() => showDropdown(context, ctrl))
                ],
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                color: primaryColor500,
                borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(borderRadiusSize1)),
              ),
              child: searchBar(context, ctrl),
            ),
            Obx(() {
              if (ctrl.isLoading) {
                return Center(child: CircularProgressIndicator());
              } else {
                return ctrl.selectedListByCategory.isEmpty
                    ? noMatchDataView()
                    : Column(
                        children: [
                          const SizedBox(height: 16),
                          Column(
                            children: ctrl.selectedListByCategory
                                .map((fieldEntity) => SportFieldCard(
                                      field: fieldEntity,
                                      isSelected: false,
                                      onLongPress: (fieldEntity) {},
                                    ))
                                .toList(),
                          ),
                        ],
                      );
              }
            }),
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
            "Sorry we couldn't find what you were looking for, \nplease try another keyword.",
            style: descTextStyle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget showDropdown(BuildContext context, SearchViewController ctrl) {
    return DropdownButton<String>(
      value: ctrl.selectedDropdownItem.isNotEmpty
          ? ctrl.selectedDropdownItem
          : null,
      iconEnabledColor: colorWhite,
      iconDisabledColor: darkBlue500,
      dropdownColor: darkBlue500,
      style: normalTextStyle.copyWith(color: colorWhite),
      icon: const Icon(Icons.filter_alt),
      isDense: false,
      isExpanded: false,
      underline: const SizedBox(),
      alignment: Alignment.centerRight,
      items: [
        DropdownMenuItem<String>(
          child: Text("All"),
          value: "All",
        ),
        ...ctrl.categoriesSportCtrl.items
            .map<DropdownMenuItem<String>>((value) => DropdownMenuItem(
                  child: Text(value.spname),
                  value: value.spname,
                ))
            .toList(),
      ],
      onChanged: (value) {
        if (value != null) {
          ctrl.selectedDropdownItem = value;
        }
      },
    );
  }

  Widget searchBar(BuildContext context, SearchViewController ctrl) {
    final TextEditingController textController =
        TextEditingController(text: ctrl.query);

    return Padding(
      padding: EdgeInsets.only(
          left: Demensions.width10 + 6,
          right: Demensions.width10 + 6,
          top: 0.0,
          bottom: Demensions.height10 + 6),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: lightBlue100,
              borderRadius: BorderRadius.circular(borderRadiusSize),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: Demensions.height10 + 6, vertical: 0.0),
              child: TextField(
                onChanged: (String value) {
                  ctrl.query = value;
                },
                onSubmitted: (String value) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, 'OK'),
                            child: const Text('OK'),
                          ),
                        ],
                        title: const Text("Hello there :)"),
                        content: const Text(
                            'Sorry, the search feature is not implemented yet'),
                      );
                    },
                  );
                },
                controller: textController,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Search...",
                  suffixIcon: Obx(() => ctrl.query.isEmpty
                      ? Container(width: 0)
                      : IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            ctrl.query = '';
                            textController.clear();
                          },
                        )),
                ),
              ),
            ),
          ),
          Obx(() {
            if (ctrl.searchSuggestions.isNotEmpty) {
              return Container(
                color: Colors.white,
                constraints: BoxConstraints(
                  maxHeight: Demensions.height20 * 10,
                ),
                child: ListView(
                  shrinkWrap: true,
                  children: ctrl.searchSuggestions.map((field) {
                    return ListTile(
                      title: Text(field.spname),
                      onTap: () {
                        ctrl.selectField(field);
                        textController.text = field.spname;
                        ctrl.searchSuggestions.clear();
                      },
                    );
                  }).toList(),
                ),
              );
            } else {
              return Container();
            }
          }),
        ],
      ),
    );
  }
}
