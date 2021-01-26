import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cabify/shared/constants.dart';
import 'package:cabify/pages/home/search_bar.dart';
import 'package:cabify/pages/home/home_drawer.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cabify/providers/geolocation_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Position currentPosition;
  double searchBarTop = 0.0;
  Completer<GoogleMapController> _controller = Completer();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> setPosition() async {
    final position =
        await context.read(geolocationProvider).getCurrentPosition();

    setState(() => currentPosition = position);

    final pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = CameraPosition(target: pos, zoom: 14);
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(cp));
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
            mapType: MapType.normal,
            myLocationEnabled: true,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              setState(() => searchBarTop = 64.0);
              setPosition();
            },
          ),
          SearchBar(
            searchBarTop: searchBarTop,
            scaffoldKey: scaffoldKey,
          ),
        ],
      ),
    );
  }
}
