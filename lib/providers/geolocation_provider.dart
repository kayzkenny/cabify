import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cabify/services/geolocation_service.dart';

final geolocationProvider = Provider((ref) => GeolocationService());
