import 'dart:io';
import 'dart:async';

import 'package:cabify/models/address_model.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabify/pages/home/home_drawer.dart';
import 'package:cabify/widgets/progress_dialog.dart';
import 'package:cabify/models/direction_details.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/providers/appstate_provider.dart';
import 'package:cabify/providers/googlemaps_provider.dart';
import 'package:cabify/providers/geolocation_provider.dart';
import 'package:cabify/providers/connectivity_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position currentPosition;
  double searchBarTop = 0.0;
  BitmapDescriptor nearbyIcon;
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};
  Set<Polyline> _polylines = {};
  double mapPaddingBottom = 0.0;
  // GoogleMapController mapController;
  List<LatLng> polylineCoordinates = [];
  DirectionDetails tripDirectionDetails;
  bool isRequestingLocationDetails = false;
  Completer<GoogleMapController> _controller = Completer();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  Future<void> fitPolylinesOnMap(
    LatLng pickLatLng,
    LatLng destinationLatLng,
  ) async {
    // make polyline fit inside the map
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

  Future<void> showDetailSheet() async {
    await getDirection();
    setState(() {
      // searchBarTop = -100.0;
      // rideDetailsSheetHeight = 270;
      // mapPaddingBottom = Platform.isIOS ? 270.0 : 300.0; // depends on platfrom
    });

    // var detailSheetController = scaffoldKey.currentState.showBottomSheet(
    //   (context) => Container(
    //     height: 270.0,
    //     color: Colors.white,
    //     padding: const EdgeInsets.all(32.0),
    //     child: Center(
    //       child: Text(
    //         'This is the modal bottom sheet. Slide down to dismiss.',
    //         textAlign: TextAlign.center,
    //         style: TextStyle(
    //           color: Theme.of(context).accentColor,
    //           fontSize: 24.0,
    //         ),
    //       ),
    //     ),
    //   ),
    // );

    // detailSheetController.close;
  }

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
      drawer: Container(
        width: 250,
        color: Colors.white,
        child: HomeDrawer(),
      ),
      body: Stack(
        children: [
          GoogleMap(
            markers: _markers,
            circles: _circles,
            polylines: _polylines,
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: _kGooglePlex,
            padding: EdgeInsets.only(bottom: mapPaddingBottom, top: 264),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setState(() => searchBarTop = 64.0);
              setPosition();
            },
          ),
          AnimatedPositioned(
            duration: const Duration(milliseconds: 500),
            curve: Curves.fastOutSlowIn,
            left: 0.0,
            right: 0.0,
            top: searchBarTop,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 32.0),
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              height: 48.0,
              // width: 360.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 5.0,
                    spreadRadius: 0.5,
                    offset: Offset(0.7, 0.7),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.centerRight,
                children: [
                  TextFormField(
                    onTap: () async {
                      var response =
                          await Navigator.pushNamed(context, '/search');

                      if (response == 'getDirection') {
                        showDetailSheet();
                      }
                    },
                    decoration: const InputDecoration(
                      // labelText: 'Where to?',
                      hintText: 'Where to?',
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.black,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                    ),
                  ),
                  IconButton(
                    // padding: EdgeInsets.all(0.0),
                    icon: Icon(Icons.menu),
                    onPressed: () {
                      scaffoldKey.currentState.openDrawer();
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
