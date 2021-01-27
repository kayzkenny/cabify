import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabify/shared/constants.dart';
import 'package:cabify/models/address_model.dart';
import 'package:cabify/widgets/taxi_widgets.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:cabify/widgets/progress_dialog.dart';
import 'package:cabify/models/direction_details.dart';
import 'package:cabify/models/ride_request_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/providers/database_provider.dart';
import 'package:cabify/providers/appstate_provider.dart';
import 'package:cabify/providers/googlemaps_provider.dart';
import 'package:cabify/providers/geolocation_provider.dart';
import 'package:cabify/providers/connectivity_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class RequestCabPage extends StatefulWidget {
  @override
  _RequestCabPageState createState() => _RequestCabPageState();
}

class _RequestCabPageState extends State<RequestCabPage> {
  String rideRefId;
  Position currentPosition;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  String appState = 'NORMAL';
  BitmapDescriptor nearbyIcon;
  double mapPaddingBottom = 0.0;
  Set<Polyline> _polylines = {};
  DirectionDetails tripDirectionDetails;
  List<LatLng> polylineCoordinates = [];
  bool isRequestingLocationDetails = false;
  PersistentBottomSheetController detailSheetController;
  PersistentBottomSheetController requestSheetController;
  Completer<GoogleMapController> _controller = Completer();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  /// make polyline fit inside the map
  Future<void> fitPolylinesOnMap(
    LatLng pickLatLng,
    LatLng destinationLatLng,
  ) async {
    LatLngBounds bounds;

    if (pickLatLng.latitude > destinationLatLng.latitude &&
        pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: destinationLatLng,
        northeast: pickLatLng,
      );
    } else if (pickLatLng.longitude > destinationLatLng.longitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          pickLatLng.latitude,
          destinationLatLng.longitude,
        ),
        northeast: LatLng(
          destinationLatLng.latitude,
          pickLatLng.longitude,
        ),
      );
    } else if (pickLatLng.latitude > destinationLatLng.latitude) {
      bounds = LatLngBounds(
        southwest: LatLng(
          destinationLatLng.latitude,
          pickLatLng.longitude,
        ),
        northeast: LatLng(
          pickLatLng.latitude,
          destinationLatLng.longitude,
        ),
      );
    } else {
      bounds = LatLngBounds(
        southwest: pickLatLng,
        northeast: destinationLatLng,
      );
    }

    final GoogleMapController controller = await _controller.future;

    controller.animateCamera(
      CameraUpdate.newLatLngBounds(bounds, 70),
    );
  }

  void drawPolylinesOnMap(DirectionDetails directionDetails) {
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(
      directionDetails.encodedPoints,
    );

    polylineCoordinates.clear();

    if (results.isNotEmpty) {
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((point) {
        polylineCoordinates.add(
          LatLng(point.latitude, point.longitude),
        );
      });
    }

    _polylines.clear();

    Polyline polyline = Polyline(
      polylineId: PolylineId('polyid'),
      color: Color.fromARGB(255, 95, 109, 237),
      points: polylineCoordinates,
      jointType: JointType.round,
      width: 4,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      geodesic: true,
    );

    setState(() => _polylines.add(polyline));
  }

  void showMarkers({
    LatLng pickLatLng,
    LatLng destinationLatLng,
    Address pickup,
    Address destination,
  }) {
    Marker pickupMarker = Marker(
      position: pickLatLng,
      markerId: MarkerId('pickup'),
      infoWindow: InfoWindow(
        title: pickup.placeName,
        snippet: 'My Location',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    Marker destinationMarker = Marker(
      position: destinationLatLng,
      markerId: MarkerId('destination'),
      infoWindow: InfoWindow(
        title: destination.placeName,
        snippet: 'Destination',
      ),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.greenAccent,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.greenAccent,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: Colors.greenAccent,
      strokeWidth: 3,
      radius: 12,
      center: pickLatLng,
      fillColor: Colors.greenAccent,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });
  }

  Future<void> getDirection() async {
    final pickup = context.read(appStateProvider).pickupAddress;
    final destination = context.read(appStateProvider).destinationAddress;
    final pickLatLng = LatLng(pickup.latitude, pickup.longitude);
    final destinationLatLng =
        LatLng(destination.latitude, destination.longitude);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProgressDialog(status: 'Please wait...'),
    );

    final thisDetails =
        await context.read(googleMapsProvider).getDirectionDetails(
              pickLatLng,
              destinationLatLng,
            );

    setState(() => tripDirectionDetails = thisDetails);
    Navigator.pop(context);

    drawPolylinesOnMap(thisDetails);
    fitPolylinesOnMap(pickLatLng, destinationLatLng);
    showMarkers(
      destination: destination,
      destinationLatLng: destinationLatLng,
      pickLatLng: pickLatLng,
      pickup: pickup,
    );
  }

  Future<void> cancelRequest() async {
    await context
        .read(databaseProvider)
        .deleteRideRequest(rideRequestId: rideRefId);
    closeRequestSheet();
    Navigator.pop(context);

    setState(() {
      appState = 'NORMAL';
    });
  }

  Future<void> createRideRequest() async {
    final pickup = context.read(appStateProvider).pickupAddress;
    final destination = context.read(appStateProvider).destinationAddress;
    final currentUserData = context.read(appStateProvider).currentUserData;
    Geoflutterfire geo = Geoflutterfire();

    final rideRequest = RideRequest(
      status: "waiting",
      riderId: currentUserData.uid,
      riderName: currentUserData.username,
      riderPhone: currentUserData.phoneNumber,
      createdAt: DateTime.now(),
      paymentMethod: "cash",
      pickupAddress: pickup.placeName,
      destinationAddress: destination.placeName,
      pickupLocation: geo
          .point(
            latitude: pickup.latitude,
            longitude: pickup.longitude,
          )
          .data,
      destinationLocation: geo
          .point(
            latitude: destination.latitude,
            longitude: destination.longitude,
          )
          .data,
    );

    final _rideRefId = await context
        .read(databaseProvider)
        .createRideRequest(rideRequest: rideRequest);

    setState(() => rideRefId = _rideRefId);
  }

  Future<void> showRequestSheet() async {
    await createRideRequest();
    var _requestSheetController = scaffoldKey.currentState.showBottomSheet(
      (context) {
        return Container(
          height: 240.0,
          padding: EdgeInsets.symmetric(vertical: 18.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                'Requesting a Ride',
                style: TextStyle(fontSize: 22.0),
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    strokeWidth: 2.0,
                    backgroundColor: Colors.transparent,
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 25),
                    onPressed: () async {
                      await cancelRequest();
                      // await resetApp();
                    },
                  ),
                ],
              ),
              Container(
                width: double.infinity,
                child: Text(
                  'Cancel Ride',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12),
                ),
              )
            ],
          ),
        );
      },
    );

    setState(() => requestSheetController = _requestSheetController);
  }

  void closeRequestSheet() => requestSheetController.close();

  Future<void> showDetailSheet() async {
    await getDirection();
    setState(() {
      // rideDetailsSheetHeight = 270;
      mapPaddingBottom = Platform.isIOS ? 270.0 : 300.0; // depends on platfrom
    });

    var _detailSheetController = scaffoldKey.currentState.showBottomSheet(
      (context) {
        return Container(
          height: 280.0,
          padding: EdgeInsets.symmetric(vertical: 18.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 15.0,
                spreadRadius: 0.5,
                offset: Offset(0.7, 0.7),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                color: Colors.greenAccent.withOpacity(0.1),
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Image.asset(
                      'images/taxi.png',
                      height: 70,
                      width: 70,
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Taxi',
                          style: TextStyle(fontSize: 18),
                        ),
                        Text(
                          '${tripDirectionDetails?.distanceText}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black38,
                          ),
                        ),
                      ],
                    ),
                    Spacer(),
                    if (tripDirectionDetails != null)
                      Text(
                        '\$${context.read(googleMapsProvider).estimateFares(tripDirectionDetails)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.monetization_on_outlined,
                      size: 18,
                      color: Colors.black38,
                    ),
                    SizedBox(width: 4),
                    Text('Cash'),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: Colors.black38,
                      size: 16,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: TaxiButton(
                  title: 'REQUEST CAB',
                  color: Colors.greenAccent,
                  onPressed: () async {
                    setState(() => appState = 'REQUESTING');
                    closeDetailSheet();
                    await showRequestSheet();
                    // availableDrivers = FireHelper.nearbyDriverList;
                    // await findDriver();
                  },
                ),
              )
            ],
          ),
        );
      },
    );

    setState(() => detailSheetController = _detailSheetController);
  }

  void closeDetailSheet() => detailSheetController.close();

  Future<void> setPosition() async {
    final position =
        await context.read(geolocationProvider).getCurrentPosition();
    setState(() => currentPosition = position);

    final pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cp));

    bool connected =
        await context.read(connectivityProvider).connectivityAvailable();

    if (connected) {
      String address = await context
          .read(geolocationProvider)
          .findCoordinateAddress(position, context);

      print(address);
    }
  }

  Future<void> createMarker() async {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(
        context,
        size: Size(2, 2),
      );

      nearbyIcon = await BitmapDescriptor.fromAssetImage(
        imageConfiguration,
        (Platform.isIOS) ? 'images/car_ios.png' : 'images/car_android.png',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Request Cab",
          style: TextStyle(color: Colors.black, fontSize: 20.0),
        ),
        backgroundColor: Colors.white,
        elevation: 0.0,
      ),
      body: GoogleMap(
        markers: _markers,
        circles: _circles,
        polylines: _polylines,
        mapType: MapType.normal,
        myLocationEnabled: true,
        initialCameraPosition: kGooglePlex,
        padding: EdgeInsets.only(bottom: mapPaddingBottom),
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
          // setState(() => searchBarTop = 64.0);
          setPosition();
          showDetailSheet();
        },
      ),
    );
  }
}
