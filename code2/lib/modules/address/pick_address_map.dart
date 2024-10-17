import 'package:code2/components/custom_btn.dart';
import 'package:code2/controllers/location_ctrl.dart';
import 'package:code2/models/demensions.dart';
import 'package:code2/modules/address/search_address.dart';
import 'package:code2/theme.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PickAddressMap extends StatefulWidget {
  final bool FrSignup;
  final bool FrAddress;
  final GoogleMapController googleMapCtrl;

  const PickAddressMap(
      {super.key,
      required this.FrSignup,
      required this.FrAddress,
      required this.googleMapCtrl});

  @override
  State<PickAddressMap> createState() => _PickAddressMapState();
}

class _PickAddressMapState extends State<PickAddressMap> {
  late LatLng _initialPo;
  late GoogleMapController _mapCtrl;
  late CameraPosition _camPo;

  @override
  void initState() {
    super.initState();
    LocationCtrl locationCtrl = Get.find<LocationCtrl>();

    if (locationCtrl.addressList.isEmpty) {
      _initialPo = LatLng(10.7351, 106.7219); // Default coordinates
    } else {
      _initialPo = LatLng(
        double.parse(locationCtrl.getAddress['latitude']),
        double.parse(locationCtrl.getAddress['longitude']),
      );
    }

    _camPo = CameraPosition(target: _initialPo, zoom: 17);
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LocationCtrl>(builder: (locationCtrl) {
      return Scaffold(
        body: SafeArea(
          child: Center(
            child: SizedBox(
              width: double.maxFinite,
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                        CameraPosition(target: _initialPo, zoom: 17),
                    zoomControlsEnabled: false,
                    onCameraMove: (CameraPosition camPo) {
                      _camPo = camPo;
                    },
                    onCameraIdle: () {
                      locationCtrl.updatePosition(_camPo, false);
                    },
                    onMapCreated: (GoogleMapController mapCtrl) {
                      _mapCtrl = mapCtrl;
                    },
                  ),
                  Center(
                    child: !locationCtrl.loading
                        ? Image.asset("assets/images/picker.png",
                            height: 50, width: 50)
                        : CircularProgressIndicator(),
                  ),
                  Positioned(
                    top: Demensions.height45,
                    left: Demensions.width20,
                    right: Demensions.width20,
                    child: InkWell(
                      onTap: () => Get.dialog(SearchAddress(mapCtrl: _mapCtrl)),
                      child: Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: Demensions.width10),
                        height: 50,
                        decoration: BoxDecoration(
                            color: primaryColor500,
                            borderRadius:
                                BorderRadius.circular(Demensions.radius20 / 2)),
                        child: Row(
                          children: [
                            Icon(Icons.location_on,
                                size: 25, color: Colors.yellow),
                            Expanded(
                                child: Text(
                              '${locationCtrl.choosePickPlacemark.name ?? 'Unnamed Place'}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: Demensions.font16),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            )),
                            SizedBox(
                              width: Demensions.width10,
                            ),
                            Icon(
                              Icons.search,
                              size: 25,
                              color: Colors.purpleAccent,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                      bottom: Demensions.height10 * 10,
                      left: Demensions.width20,
                      right: Demensions.width20,
                      child: CustomBtn(
                        btnTxt: 'Pick Address',
                        onPress: locationCtrl.loading
                            ? null
                            : () {
                                if (locationCtrl.choosePickPosition.latitude !=
                                        0 &&
                                    locationCtrl.choosePickPlacemark.name !=
                                        null) {
                                  if (widget.FrAddress &&
                                      widget.googleMapCtrl != null) {
                                    widget.googleMapCtrl.moveCamera(
                                      CameraUpdate.newCameraPosition(
                                        CameraPosition(
                                          target: LatLng(
                                            locationCtrl
                                                .choosePickPosition.latitude,
                                            locationCtrl
                                                .choosePickPosition.longitude,
                                          ),
                                        ),
                                      ),
                                    );
                                    locationCtrl.setAddressData();
                                  }

                                  Get.back();
                                } else {
                                  Get.snackbar(
                                    "Error",
                                    "Please select a valid address",
                                    snackPosition: SnackPosition.BOTTOM,
                                    backgroundColor: Colors.red,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                      ))
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
