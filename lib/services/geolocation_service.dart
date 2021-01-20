import 'package:geolocator/geolocator.dart';

class GeolocationService {
  Future<Position> getCurrentPosition({
    LocationAccuracy desiredAccuracy = LocationAccuracy.bestForNavigation,
  }) async =>
      await Geolocator.getCurrentPosition(desiredAccuracy: desiredAccuracy);

  Future<Position> get getLastKnownPosition async =>
      await Geolocator.getLastKnownPosition();
}
