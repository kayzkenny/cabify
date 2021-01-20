import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cabify/pages/home/search_bar.dart';
import 'package:cabify/pages/home/home_drawer.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cabify/providers/geolocation_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchBarTop = useState(0.0);
    final scaffoldKey = GlobalKey<ScaffoldState>();
    Completer<GoogleMapController> _controller = Completer();
    // GoogleMapController mapController;
    final currentPosition = useState<Position>();

    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

    Future<void> setPosition() async {
      final position =
          await context.read(geolocationProvider).getCurrentPosition();
      currentPosition.value = position;

      final pos = LatLng(position.latitude, position.longitude);
      CameraPosition cp = CameraPosition(target: pos, zoom: 14);
      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(cp));
    }

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
            myLocationButtonEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              searchBarTop.value = 64.0;
              await setPosition();
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
