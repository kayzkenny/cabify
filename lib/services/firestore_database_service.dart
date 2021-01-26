import 'package:cabify/services/firestore_service.dart';
import 'package:cabify/shared/firestore_path.dart';
import 'package:meta/meta.dart';
import 'package:cabify/models/user_data_model.dart';

abstract class Database {
  /// Return [UserData] as a stream
  Stream<UserData> get userDataStream;

  /// Return [UserData] as a future
  Future<UserData> get userDataFuture;

  /// Updates user data with [UserData]
  Future<void> updateUserData({@required UserData userData});

  /// Creates a ride quest

}

class FirestoreDatabase implements Database {
  FirestoreDatabase({@required this.uid}) : assert(uid != null);

  final String uid;
  final _service = FirestoreService.instance;

  @override
  Stream<UserData> get userDataStream {
    return _service.documentStream(
      path: FirestorePath.userData(uid),
      builder: (data, documentId) => UserData.fromMap(data, documentId),
    );
  }

  @override
  Future<UserData> get userDataFuture {
    return _service.documentFuture(
      path: FirestorePath.userData(uid),
      builder: (data, documentId) => UserData.fromMap(data, documentId),
    );
  }

  @override
  Future<void> updateUserData({@required UserData userData}) async {
    _service.updateData(
      path: FirestorePath.userData(uid),
      data: userData.toMap(),
    );
  }
}
