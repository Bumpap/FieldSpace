import 'package:code2/components/app_text_field.dart';
import 'package:code2/controllers/location_ctrl.dart';
import 'package:code2/controllers/users_ctrl.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/modules/address/pick_address_map.dart';
import 'package:code2/route/route_view.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/big_text.dart';
import 'package:code2/widgets/big_text7.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../models/address.dart';
import '../../widgets/big_text4.dart';

class AddressView extends StatefulWidget {
  const AddressView({super.key});

  @override
  State<AddressView> createState() => _AddressViewState();
}

class _AddressViewState extends State<AddressView> {
  TextEditingController _addressCtrl = TextEditingController();
  final TextEditingController _contactUserName = TextEditingController();
  final TextEditingController _contactUserPhoneNumber = TextEditingController();
  late bool _islogged;
  CameraPosition _cameraPosition =
      CameraPosition(target: LatLng(10.7351, 106.7219), zoom: 17);
  late LatLng _initalPosition = LatLng(10.7351, 106.7219);

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    User? user = FirebaseAuth.instance.currentUser;
    _islogged = user!.uid.isNotEmpty ? true : false;
    if (_islogged && Get.find<UsersCtrl>().currentUser.value == null) {
      Get.find<UsersCtrl>().fetchCurrentUser();
    }
    if (Get.find<LocationCtrl>().addressList.isNotEmpty) {
      _cameraPosition = CameraPosition(
        target: LatLng(
          double.parse(Get.find<LocationCtrl>().getAddress['latitude']),
          double.parse(Get.find<LocationCtrl>().getAddress['longitude']),
        ),
      );
      _initalPosition = LatLng(
        double.parse(Get.find<LocationCtrl>().getAddress['latitude']),
        double.parse(Get.find<LocationCtrl>().getAddress['longitude']),
      );
    }
    Address? address = await Get.find<LocationCtrl>().getUserAddress();
    if (address != null) {
      _addressCtrl.text = address.address;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BigText7(text: "Address View"),
        backgroundColor: primaryColor500,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: GetBuilder<UsersCtrl>(
        builder: (userCtrl) {
          if (userCtrl.currentUser.value != null &&
              _contactUserName.text.isEmpty) {
            _contactUserName.text = '${userCtrl.currentUser.value?.name}';
            _contactUserPhoneNumber.text =
                '${userCtrl.currentUser.value?.phoneNb}';
            if (Get.find<LocationCtrl>().addressList.isNotEmpty) {
              Get.find<LocationCtrl>().getUserAddress().then((address) {
                if (address != null) {
                  _addressCtrl.text = address.address;
                } else {
                  _addressCtrl.text = 'Unknown Location';
                }
              });
            }
          }
          return GetBuilder<LocationCtrl>(
            builder: (locationCtrl) {
              _addressCtrl.text = '${locationCtrl.placemark.name ?? ''}'
                  '${locationCtrl.placemark.locality ?? ''}'
                  '${locationCtrl.placemark.postalCode ?? ''}'
                  '${locationCtrl.placemark.country ?? ''}';
              print("_addressCtrl text: ${_addressCtrl.text}");
              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 140,
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.only(left: 5, right: 5, top: 5),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border: Border.all(width: 2, color: primaryColor500)),
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                                target: _initalPosition, zoom: 17),
                            onTap: (LatLng) {
                              Get.toNamed(RouteView.getPickMap(),
                                  arguments: PickAddressMap(
                                    FrSignup: false,
                                    FrAddress: true,
                                    googleMapCtrl: locationCtrl.mapCtrl,
                                  ));
                            },
                            zoomControlsEnabled: false,
                            compassEnabled: false,
                            indoorViewEnabled: true,
                            mapToolbarEnabled: false,
                            myLocationButtonEnabled: true,
                            onCameraIdle: () {
                              locationCtrl.updatePosition(
                                  _cameraPosition, true);
                            },
                            onCameraMove: ((position) =>
                                _cameraPosition = position),
                            onMapCreated: (GoogleMapController mapCtrl) {
                              locationCtrl.setMapController(mapCtrl);
                            },
                          )
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: Demensions.width20, top: Demensions.height20),
                      child: SizedBox(
                        height: 50,
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: locationCtrl.addressTypeList.length,
                            itemBuilder: (context, index) {
                              return InkWell(
                                onTap: () {
                                  locationCtrl.setAddressTypeIndex(index);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: Demensions.width20,
                                      vertical: Demensions.height10),
                                  margin: EdgeInsets.only(
                                      right: Demensions.width10),
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          Demensions.radius20 / 4),
                                      color: Theme.of(context).cardColor,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey[200]!,
                                            spreadRadius: 1,
                                            blurRadius: 5)
                                      ]),
                                  child: Icon(
                                    index == 0
                                        ? Icons.home_filled
                                        : index == 1
                                            ? Icons.work
                                            : Icons.location_on,
                                    color:
                                        locationCtrl.addressTypeIndex == index
                                            ? primaryColor500
                                            : Theme.of(context).disabledColor,
                                  ),
                                ),
                              );
                            }),
                      ),
                    ),
                    SizedBox(
                      height: Demensions.height20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Demensions.width20),
                      child: BigText(
                        text: "Address",
                      ),
                    ),
                    SizedBox(
                      height: Demensions.height10,
                    ),
                    AppTextField(
                      txtCtrl: _addressCtrl,
                      hintTxt: "Your address",
                      iconData: Icons.map,
                    ),
                    SizedBox(
                      height: Demensions.height20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Demensions.width20),
                      child: BigText(
                        text: "Name",
                      ),
                    ),
                    SizedBox(
                      height: Demensions.height10,
                    ),
                    AppTextField(
                        txtCtrl: _contactUserName,
                        hintTxt: "Your name",
                        iconData: Icons.person),
                    SizedBox(
                      height: Demensions.height20,
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: Demensions.width20),
                      child: BigText(
                        text: "Phone Number",
                      ),
                    ),
                    SizedBox(
                      height: Demensions.height10,
                    ),
                    AppTextField(
                        txtCtrl: _contactUserPhoneNumber,
                        hintTxt: "Your Phone Number",
                        iconData: Icons.phone)
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: Demensions.bottomHeightBar - 10,
            padding: EdgeInsets.only(
                top: Demensions.height30,
                bottom: Demensions.height30,
                left: Demensions.width20,
                right: Demensions.width20),
            decoration: BoxDecoration(
              color: Theme.of(context).dialogBackgroundColor,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(Demensions.radius20 * 2),
                topRight: Radius.circular(Demensions.radius20 * 2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    final locationCtrl = Get.find<LocationCtrl>();
                    Address _address = Address(
                      addressType: locationCtrl
                          .addressTypeList[locationCtrl.addressTypeIndex],
                      contactUserName: _contactUserName.text,
                      contactUserPhoneNumber: _contactUserPhoneNumber.text,
                      address: _addressCtrl.text,
                      latitude: locationCtrl.position.latitude.toString(),
                      longitude: locationCtrl.position.longitude.toString(),
                    );
                    try {
                      await locationCtrl.addAddress(_address);
                      Get.back();
                      Get.snackbar("Address", "Saved Successfully",
                          colorText: Colors.white,
                          backgroundColor: Colors.green);
                    } catch (e) {
                      Get.snackbar("Address", "Couldn't save address",
                          colorText: Colors.white, backgroundColor: Colors.red);
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.all(Demensions.height20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Demensions.radius20),
                      color: primaryColor200,
                    ),
                    child: BigText4(text: "Save Address"),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
