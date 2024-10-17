import 'package:code2/models/demensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:search_map_location/utils/google_search/place.dart';

import '../../controllers/location_ctrl.dart';

class SearchAddress extends StatelessWidget {
  final GoogleMapController mapCtrl;
  final LocationCtrl locationCtrl = Get.find();

  SearchAddress({Key? key, required this.mapCtrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _txtCtrl = TextEditingController();

    return Container(
      padding: EdgeInsets.all(Demensions.width10),
      alignment: Alignment.topCenter,
      child: Material(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(Demensions.radius20 / 2),
        ),
        child: SizedBox(
          width: Demensions.screenWidth,
          child: TypeAheadField<Place>(
            textFieldConfiguration: TextFieldConfiguration(
              controller: _txtCtrl,
              textInputAction: TextInputAction.search,
              autofocus: true,
              textCapitalization: TextCapitalization.words,
              keyboardType: TextInputType.streetAddress,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(Demensions.radius20 / 2),
                ),
                hintText: 'Search address',
              ),
            ),
            suggestionsCallback: (String pattern) async {
              if (pattern.isNotEmpty) {
                final List<Place> places =
                    await locationCtrl.fetchSearchResults(pattern);
                return places;
              }
              return <Place>[];
            },
            itemBuilder: (BuildContext context, Place place) {
              return ListTile(
                title: Text(place.description ?? ''),
              );
            },
            onSuggestionSelected: (Place suggestion) {
              locationCtrl
                  .getCoordinatesFromAddress(suggestion.description ?? '')
                  .then((LatLng coordinates) {
                mapCtrl.animateCamera(CameraUpdate.newLatLng(coordinates));
              });
            },
          ),
        ),
      ),
    );
  }
}
