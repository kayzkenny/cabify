import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/services/geolocation_service.dart';

final geolocationProvider = Provider((ref) => GeolocationService());
