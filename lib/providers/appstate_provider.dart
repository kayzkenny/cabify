import 'package:flutter/foundation.dart';
import 'package:cabify/models/address_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appStateProvider = Provider(
  (ref) => AppState(),
);

class AppState extends ChangeNotifier {
  Address pickupAddress;
  Address destinationAddress;

  void updatePickupAddress(Address pickup) {
    pickupAddress = pickup;
    notifyListeners();
  }

  void updateDestinationAddress(Address destination) {
    destinationAddress = destination;
    notifyListeners();
  }
}
