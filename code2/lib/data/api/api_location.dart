import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/data/repos/location_repo.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:search_map_location/utils/google_search/geo_coding.dart';
import 'package:search_map_location/utils/google_search/place.dart';
import '../../models/address.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiLocation extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final String _googleApiKey = "AIzaSyDKNXy5yWoDcs5X6xP-sS9Q8A3DB_6AYgM";
  final Geocoding _geocoding = Geocoding(apiKey: "AIzaSyDKNXy5yWoDcs5X6xP-sS9Q8A3DB_6AYgM", language: "us");

  Future<List<Address>> getData(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('location')
          .where('userID', isEqualTo: userId)
          .get();

      List<Address> addressList = [];

      for (var doc in snapshot.docs) {
        List<dynamic> addressesData = doc['addresses'] ?? [];
        List<Address> addresses = addressesData
            .map((item) => Address.fromJson(item as Map<String, dynamic>))
            .toList();
        addressList.addAll(addresses);
      }

      return addressList;
    } catch (e) {
      throw Exception('Error fetching data from Firestore: $e');
    }
  }

  Future<List<Placemark>> getAddressfromGeocode(LatLng lat) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat.latitude, lat.longitude);
    return placemarks;
  }

  Future<Map<String, dynamic>> getUserAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return {
          'latitude': '',
          'longitude': '',
          'address': 'Location services are disabled.',
        };
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return {
            'latitude': '',
            'longitude': '',
            'address': 'Location permissions are denied.',
          };
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return {
          'latitude': '',
          'longitude': '',
          'address': 'Location permissions are permanently denied.',
        };
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng latLng = LatLng(position.latitude, position.longitude);
      List<Placemark> placemarks = await getAddressfromGeocode(latLng);

      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        return {
          'latitude': latLng.latitude.toString(),
          'longitude': latLng.longitude.toString(),
          'address': '${placemark.name}, ${placemark.locality}, ${placemark.postalCode}, ${placemark.country}',
        };
      } else {
        return {
          'latitude': latLng.latitude.toString(),
          'longitude': latLng.longitude.toString(),
          'address': 'Unknown Location',
        };
      }
    } catch (e) {
      print('Error getting user location: $e');
      return {
        'latitude': '',
        'longitude': '',
        'address': 'Error getting location',
      };
    }
  }

  Future<void> postData(LocationRepo locationRepo) async {
    try {
      QuerySnapshot querySnapshot = await _firestore.collection('location')
          .where('userID', isEqualTo: locationRepo.userID)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentReference docRef = querySnapshot.docs.first.reference;
        await docRef.update(locationRepo.toJson());
        print('Location updated successfully');
      } else {
        DocumentReference docRef = await _firestore.collection('location').add(locationRepo.toJson());
        print('Location added successfully with ID: ${docRef.id}');
      }
    } catch (e) {
      print('Error posting location data to Firestore: $e');
    }
  }

  Future<LatLng> getCoordinatesFromAddress(String address) async {
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return LatLng(locations[0].latitude, locations[0].longitude);
    } else {
      throw Exception('Địa chỉ không hợp lệ');
    }
  }

  Future<LatLng> getStartPoint(String userID) async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('location')
          .where('userID', isEqualTo: userID)
          .get();

      if (snapshot.docs.isNotEmpty) {
        DocumentSnapshot doc = snapshot.docs.first;
        List<dynamic> addressesData = doc['addresses'] ?? [];

        if (addressesData.isNotEmpty) {
          Map<String, dynamic> firstAddress = addressesData.first as Map<String, dynamic>;
          double latitude = double.parse(firstAddress['latitude']);
          double longitude = double.parse(firstAddress['longitude']);

          return LatLng(latitude, longitude);
        } else {
          throw Exception('No addresses found for this user.');
        }
      } else {
        throw Exception('No location document found for this user.');
      }
    } catch (e) {
      throw Exception('Error fetching latitude and longitude: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getAllData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('location').get();
      List<Map<String, dynamic>> locationData = [];

      for (var doc in snapshot.docs) {
        locationData.add(doc.data() as Map<String, dynamic>);
      }

      return locationData;
    } catch (e) {
      throw Exception('Error fetching all data from Firestore: $e');
    }
  }

  // Future<List<Prediction>> getSearchAddress(String inputText) async {
  //   final String endpoint = 'https://maps.googleapis.com/maps/api/place/autocomplete/json';
  //   final String url = '$endpoint?input=$inputText&key=$_googleApiKey';
  //
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       final data = json.decode(response.body);
  //       final predictions = data['predictions'] as List<dynamic>;
  //       return predictions.map((p) => Prediction.fromJson(p)).toList();
  //     } else {
  //       throw Exception('Failed to load search results');
  //     }
  //   } catch (e) {
  //     print('Error fetching search results: $e');
  //     rethrow;
  //   }
  // }

  Future<List<Place>> getSearchAddress(String inputText) async {
    try {
      print("_geocoding: ${_geocoding.getGeolocation(inputText).toString()}");
      final result = await _geocoding.getGeolocation(inputText);
      final List<dynamic> results = result["results"] as List<dynamic>;
      return results.map((place) => Place.fromJSON(place, _geocoding)).toList();
    } catch (e) {
      print('Error fetching search results: $e');
      rethrow;
    }
  }
}
