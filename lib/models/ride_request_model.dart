import 'package:flutter/foundation.dart';
// import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  final String id;
  final String status;
  final String riderId;
  final String driverId;
  final String riderName;
  final String riderPhone;
  final String paymentMethod;
  final String pickupAddress;
  final String destinationAddress;
  final DateTime createdAt;
  final Map pickupLocation;
  final Map destinationLocation;

  RideRequest({
    this.id,
    this.driverId,
    @required this.status,
    @required this.riderId,
    @required this.riderName,
    @required this.riderPhone,
    @required this.createdAt,
    @required this.paymentMethod,
    @required this.pickupAddress,
    @required this.destinationAddress,
    @required this.pickupLocation,
    @required this.destinationLocation,
  });

  /// Convert userData to map such as a firestore document
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'paymentMethod': paymentMethod,
      'pickupAddress': pickupAddress,
      'destinationAddress': destinationAddress,
      'createdAt': Timestamp.fromDate(createdAt),
      'pickupLocation': pickupLocation,
      'destinationLocation': destinationLocation,
    };
  }

  // TODO: to update the driverId or status use the updatefield method on the firestore service

  /// Construct userData from a map sucg as a firestore document
  factory RideRequest.fromMap(
    Map<String, dynamic> data,
    String documentId,
  ) {
    if (data == null) {
      return null;
    }

    final String status = data['status'];
    final String riderId = data['riderId'];
    final String driverId = data['driverId'];
    final String riderName = data['riderName'];
    final String riderPhone = data['riderPhone'];
    final String paymentMethod = data['paymentMethod'];
    final String pickupAddress = data['pickupAddress'];
    final String destinationAddress = data['destinationAddress'];
    final Timestamp createdAt = data['createdAt'];
    final Map pickupLocation = data['pickupLocation']['geopoint'];
    final Map destinationLocation = data['destinationLocation']['geopoint'];

    return RideRequest(
      id: documentId,
      status: status,
      riderId: riderId,
      driverId: driverId ?? null,
      riderName: riderName ?? null,
      riderPhone: riderPhone ?? null,
      paymentMethod: paymentMethod ?? null,
      pickupAddress: pickupAddress ?? null,
      destinationAddress: destinationAddress ?? null,
      createdAt: createdAt?.toDate() ?? null,
      pickupLocation: pickupLocation ?? null,
      destinationLocation: destinationLocation ?? null,
    );
  }
}
