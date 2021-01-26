class UserData {
  final String uid;
  final String email;
  final String username;
  final String avatarURL;
  final String phoneNumber;

  UserData({
    this.uid,
    this.email,
    this.username,
    this.avatarURL,
    this.phoneNumber,
  });

  /// Convert userData to map such as a firestore document
  Map<String, dynamic> toMap() {
    return {
      'username': username,
      'phoneNumber': phoneNumber,
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
    final String phoneNumber = data['phoneNumber'];

    return UserData(
      email: email,
      uid: documentId,
      username: username ?? null,
      avatarURL: avatarURL ?? null,
      phoneNumber: phoneNumber ?? null,
    );
  }
}
