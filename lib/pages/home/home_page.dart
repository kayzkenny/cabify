import 'dart:async';

import 'package:flutter/material.dart';
// import 'package:cabify/shared/constants.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:cabify/pages/home/search_bar.dart';
import 'package:cabify/pages/home/home_drawer.dart';
// import 'package:hooks_riverpod/hooks_riverpod.dart';
// import 'package:cabify/providers/auth_provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomePage extends HookWidget {
  @override
  Widget build(BuildContext context) {
    final searchBarTop = useState(0.0);
    final scaffoldKey = GlobalKey<ScaffoldState>();

    Completer<GoogleMapController> _controller = Completer();

    final CameraPosition _kGooglePlex = CameraPosition(
      target: LatLng(37.42796133580664, -122.085749655962),
      zoom: 14.4746,
    );

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
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              searchBarTop.value = 64.0;
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
