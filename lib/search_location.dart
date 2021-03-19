import 'package:firebase_database/firebase_database.dart';
import 'package:geocoder/geocoder.dart';
import 'package:geolocator/geolocator.dart';

import 'convert_coordinates.dart';

class SearchLocation {
  SearchLocation();

  Coordinates coordinates;
  double minDistance = double.infinity;
  String locationSelected;

  Future<dynamic> _calculateDistance(
      double lat, double long, Coordinates myCoordinates) async {
    if (myCoordinates != null) {
      double dist = await Geolocator().distanceBetween(
          lat, long, myCoordinates.latitude, myCoordinates.longitude);
      return (dist);
    }
  }

  String searchLocation() {
    DatabaseReference locationRef =
        FirebaseDatabase.instance.reference().child('locations');
    Map<String, dynamic> mapOfMaps;

    locationRef.once().then((DataSnapshot snapshot) {
      mapOfMaps = Map.from(snapshot.value);

      mapOfMaps.forEach((key, value) async {
        ConvertCoordinates convertCoordinates =
            new ConvertCoordinates(oldCoordinates: key);
        List<String> locationCoordinates =
            convertCoordinates.convertCoordinates();
        double distance = await _calculateDistance(
            double.parse(locationCoordinates[0]),
            double.parse(locationCoordinates[1]),
            coordinates);

        if (distance < minDistance) {
          minDistance = distance;
          locationSelected = key;
        }
      });
    });
    return locationSelected;
  }

  String getSearchedLocation() {
    searchLocation();
    return locationSelected;
  }
}
