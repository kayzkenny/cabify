import 'package:flutter/foundation.dart';

class User {
  User({
    @required this.uid,
    this.photoUrl,
    this.displayName,
  });
  final String uid;
  final String photoUrl;
  final String displayName;
}
