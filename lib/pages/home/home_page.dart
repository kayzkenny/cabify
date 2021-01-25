import 'dart:async';

import 'package:cabify/models/direction_details.dart';
import 'package:cabify/providers/appstate_provider.dart';
import 'package:cabify/providers/googlemaps_provider.dart';
import 'package:cabify/widgets/progress_dialog.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabify/pages/home/search_bar.dart';
import 'package:cabify/pages/home/home_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/providers/geolocation_provider.dart';
import 'package:cabify/providers/connectivity_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position currentPosition;
  double searchBarTop = 0.0;
  double mapPaddingBottom = 0.0;
  GoogleMapController mapController;
  List<LatLng> polylineCoordinates = [];
  DirectionDetails tripDirectionDetails;
  bool isRequestingLocationDetails = false;
  Completer<GoogleMapController> _controller = Completer();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

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

    print('----- encoded points -----------');
    print(thisDetails.encodedPoints);
  }

  Future<void> showDetailSheet() async {
    await getDirection();
    // setState(() {
    // searchBarTop = 0.0;
    // rideDetailsSheetHeight = 270;
    // mapBottomPadding = 0; depends on platfrom
    // });
    // showModalBottomSheet<void>(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return Container(
    //       child: Padding(
    //         padding: const EdgeInsets.all(32.0),
    //         child: Text(
    //           'This is the modal bottom sheet. Slide down to dismiss.',
    //           textAlign: TextAlign.center,
    //           style: TextStyle(
    //             color: Theme.of(context).accentColor,
    //             fontSize: 24.0,
    //           ),
    //         ),
    //       ),
    //     );
    //   },
    // );
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

  @override
  Widget build(BuildContext context) {
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
            padding: EdgeInsets.only(bottom: mapPaddingBottom),
            initialCameraPosition: _kGooglePlex,
            myLocationEnabled: true,
            mapType: MapType.normal,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              setState(() => searchBarTop = 64.0);
              await setPosition();
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
