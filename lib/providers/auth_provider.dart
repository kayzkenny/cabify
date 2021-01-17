import 'package:cabify/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authProvider = Provider((ref) => AuthService());
