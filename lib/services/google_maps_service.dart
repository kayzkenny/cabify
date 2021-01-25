import 'package:cabify/shared/api_keys.dart';
import 'package:cabify/shared/endpoints.dart';
import 'package:cabify/services/request_helper.dart';
import 'package:cabify/models/direction_details.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class GoogleMapsService {
  Future<DirectionDetails> getDirectionDetails(
    LatLng startPosition,
    LatLng endPosition,
  ) async {
    String url =
        '$directionsEndpoint?origin=${startPosition.latitude},${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=${APIKeys.googleMaps}';
    var response = await RequestHelper.getRequest(url);

    if (response == 'failed') {
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails(
      durationText: response['routes'][0]['legs'][0]['duration']['text'],
      durationValue: response['routes'][0]['legs'][0]['duration']['value'],
      distanceText: response['routes'][0]['legs'][0]['distance']['text'],
      distanceValue: response['routes'][0]['legs'][0]['distance']['value'],
      encodedPoints: response['routes'][0]['overview_polyline']['points'],
    );

    return directionDetails;
  }

  int estimateFares(DirectionDetails details) {
    // per km = $0.3, per min = $0.2, base fare = $3,

    double baseFare = 3;
    double distanceFare = (details.distanceValue / 1000) * 0.3;
    double timeFare = (details.durationValue / 60) * 0.2;
    double totalFare = baseFare + distanceFare + timeFare;

    return totalFare.truncate();
  }
}
