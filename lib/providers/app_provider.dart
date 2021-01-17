import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final firebaseAppProvider = FutureProvider<FirebaseApp>(
  (ref) async => await Firebase.initializeApp(),
);
