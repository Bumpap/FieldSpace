import 'package:code2/data/api/api_location.dart';
import 'package:code2/data/repos/location_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:search_map_location/utils/google_search/place.dart';

import '../models/address.dart';

class LocationCtrl extends GetxController implements GetxService {
  ApiLocation _apiLocation = Get.find();

  bool _loading = false;

  bool get loading => _loading;
  late Position _position;
  late Position _choosePickPosition;

  Position get position => _position;

  Position get choosePickPosition => _choosePickPosition;
  Placemark _placemark = Placemark();
  Placemark _choosePickPlacemark = Placemark();

  Placemark get placemark => _placemark;

  Placemark get choosePickPlacemark => _choosePickPlacemark;
  List<Address> _addressList = [];
  late List<Address> _allAddressList;

  List<Address> get addressList => _addressList;
  final List<String> _addressTypeList = ['home', 'office', 'others'];

  List<String> get addressTypeList => _addressTypeList;
  int _addressTypeIndex = 0;

  int get addressTypeIndex => _addressTypeIndex;
  late Map<String, dynamic> _getAddress;

  Map get getAddress => _getAddress;
  bool _changeAddress = true;
  RxList<Address> address = <Address>[].obs;
  RxList<Address> allAddress = <Address>[].obs;
  RxList<LocationRepo> items = RxList<LocationRepo>();

  late GoogleMapController _mapCtrl;

  GoogleMapController get mapCtrl => _mapCtrl;
  bool _updateAddressData = true;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchAllLocationData();
  }

  Future<void> fetchAllLocationData() async {
    _loading = true;
    update();
    try {
      List<Map<String, dynamic>> locationData = await _apiLocation.getAllData();

      _addressList =
          locationData.map((data) => Address.fromJson(data)).toList();
      _allAddressList =
          locationData.map((data) => Address.fromJson(data)).toList();

      allAddress.assignAll(_addressList);

      print("Fetched all location data successfully.");
    } catch (e) {
      print("Error fetching all location data: $e");
    } finally {
      _loading = false;
      update();
    }
  }

  void fetchData() async {
    _loading = true;
    update();
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        List<Address> data = await Get.find<ApiLocation>().getData(user.uid);
        address.assignAll(data);
      } else {
        print('User not logged in.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    } finally {
      _loading = false;
      update();
    }
  }

  void setMapController(GoogleMapController mapCtrl) {
    _mapCtrl = mapCtrl;
    fetchData();
  }

  Future<void> updatePosition(
      CameraPosition cameraPosition, bool addressFrom) async {
    if (_updateAddressData) {
      _loading = true;
      update();
      try {
        Position newPosition = Position(
          latitude: cameraPosition.target.latitude,
          longitude: cameraPosition.target.longitude,
          timestamp: DateTime.now(),
          heading: 1,
          accuracy: 1,
          altitude: 1,
          speedAccuracy: 1,
          speed: 1,
          altitudeAccuracy: 1,
          headingAccuracy: 1,
        );

        if (addressFrom) {
          _position = newPosition;
        } else {
          _choosePickPosition = newPosition;
        }

        if (_changeAddress) {
          String address = await getAddressfromGeocode(LatLng(
            cameraPosition.target.latitude,
            cameraPosition.target.longitude,
          ));
          print("name address: ${address}");
          if (addressFrom) {
            _placemark = Placemark(name: address);
          } else {
            _choosePickPlacemark = Placemark(name: address);
          }
        }
      } catch (e) {
        print(e);
      } finally {
        _loading = false;
        update();
        fetchData();
      }
    } else {
      _updateAddressData = true;
    }
  }

  Future<String> getAddressfromGeocode(LatLng latLng) async {
    _loading = true;
    update();
    String address = "Unknown Location Found";
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(latLng.latitude, latLng.longitude);
      if (placemarks.isNotEmpty) {
        address = placemarks.first.name ?? address;
      } else {
        print("Error getting the Google API");
      }
    } catch (e) {
      print("Error fetching geocode: $e");
    } finally {
      _loading = false;
      update();
    }
    return address;
  }

  Future<Address?> getUserAddress() async {
    _loading = true;
    update();
    Address? _address;
    try {
      _getAddress = await _apiLocation.getUserAddress();
      if (_getAddress.isNotEmpty) {
        _address = Address.fromJson(_getAddress);
        update();
      }
    } catch (e) {
      print("Error getting user address: $e");
    } finally {
      _loading = false;
      update();
    }
    fetchData();
    return _address;
  }

  void setAddressTypeIndex(int index) {
    _addressTypeIndex = index;
    update();
    fetchData();
  }

  Future<LatLng> getCoordinatesFromAddress(String address) async {
    _loading = true;
    update();
    try {
      return await Get.find<ApiLocation>().getCoordinatesFromAddress(address);
    } catch (e) {
      print("Error fetching coordinates: $e");
      rethrow;
    } finally {
      _loading = false;
      update();
    }
  }

  Future<void> addAddress(Address address) async {
    _loading = true;
    update();
    try {
      User? user = FirebaseAuth.instance.currentUser;
      String userId = user?.uid ?? '';

      LocationRepo locationRepo = LocationRepo(
        id: '',
        userID: userId,
        addresses: [address],
      );

      await _apiLocation.postData(locationRepo);
    } catch (e) {
      print("Error adding address: $e");
      rethrow;
    } finally {
      _loading = false;
      update();
    }
    fetchData();
  }

  double calculateDistance(LatLng start, LatLng end) {
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      end.latitude,
      end.longitude,
    );
  }

  Future<LatLng> getStartPoint(String userID) async {
    _loading = true;
    update();
    try {
      return await Get.find<ApiLocation>().getStartPoint(userID);
    } catch (e) {
      print("Error fetching start point: $e");
      rethrow;
    } finally {
      _loading = false;
      update();
    }
  }

  void setAddressData() {
    _position = _choosePickPosition;
    _placemark = _choosePickPlacemark;
    _updateAddressData = false;
    update();
  }

  Future<List<Place>> fetchSearchResults(String inputText) async {
    try {
      List<Place> predictions = await _apiLocation.getSearchAddress(inputText);
      return predictions;
    } catch (e) {
      print('Error fetching search results: $e');
      return [];
    }
  }
}
