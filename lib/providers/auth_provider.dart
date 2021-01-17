import 'package:cabify/models/user_model.dart';
import 'package:cabify/services/auth_service.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final authServiceProvider = Provider(
  (ref) => AuthService(),
);

final authStateProvider = StreamProvider.autoDispose<User>(
  (ref) => AuthService().onAuthStateChanged,
);
