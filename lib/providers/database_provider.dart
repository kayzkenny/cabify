import 'package:cabify/models/user_data_model.dart';
import 'package:cabify/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/services/firestore_database_service.dart';

final databaseProvider = Provider<FirestoreDatabase>(
  (ref) =>
      FirestoreDatabase(uid: ref.watch(authServiceProvider).currentUser().uid),
);

final userDataProvider = StreamProvider.autoDispose<UserData>(
  (ref) => ref.read(databaseProvider).userDataStream,
);
