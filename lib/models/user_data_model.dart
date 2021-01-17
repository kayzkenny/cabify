class UserData {
  final String uid;
  final String email;
  final String username;
  final String avatarURL;

  UserData({
    this.uid,
    this.email,
    this.username,
    this.avatarURL,
  });

  /// Convert userData to map such as a firestore document
  Map<String, dynamic> toMap() {
    return {
      'username': username,
    };
  }

  /// Construct userData from a map sucg as a firestore document
  factory UserData.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    if (data == null) {
      return null;
    }

    final String email = data['email'];
    final String username = data['username'];
    final String avatarURL = data['avatarURL'];

    return UserData(
      email: email,
      uid: documentId,
      username: username ?? null,
      avatarURL: avatarURL ?? null,
    );
  }
}
