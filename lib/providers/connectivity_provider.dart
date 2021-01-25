import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/services/connectivity_service.dart';

final connectivityProvider = Provider((ref) => ConnectivityService());
