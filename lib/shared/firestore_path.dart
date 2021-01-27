class FirestorePath {
  static String users() => 'users';
  static String rideRequests() => 'riderequests';
  static String userData(String uid) => 'users/$uid';
  static String rideRequest(String rideRequestId) =>
      'riderequests/$rideRequestId';
}
