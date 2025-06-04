import 'package:geolocator/geolocator.dart';

class Coordinates {
  final double latitude;
  final double longitude;

  Coordinates({required this.latitude, required this.longitude});

  static Coordinates parseCoordinates(String str) {
    var parts = str.split(',');
    return Coordinates(
      latitude: double.parse(parts[0]),
      longitude: double.parse(parts[1]),
    );
  }

  double distanceTo(Coordinates other) {
    return Geolocator.distanceBetween(
      latitude,
      longitude,
      other.latitude,
      other.longitude,
    );
  }
}
