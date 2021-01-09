import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:here_sdk/core.dart';
import 'package:here_sdk/mapview.dart';

class MyFlutterMap extends StatefulWidget {
  @override
  _MyFlutterMapState createState() => _MyFlutterMapState();
}

class _MyFlutterMapState extends State<MyFlutterMap> {
  GeoCoordinates _myPosition;
  HereMapController _myHereMapController;

  void _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permantly denied, we cannot request permissions.');
    }

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        return Future.error(
            'Location permissions are denied (actual value: $permission).');
      }
    }

    Position p = await Geolocator.getCurrentPosition();
    _myPosition = GeoCoordinates(p.latitude, p.longitude);
    const double distanceToEarthInMeters = 8000;
    _myHereMapController.camera
        .lookAtPointWithDistance(_myPosition, distanceToEarthInMeters);
    ByteData fileData = await rootBundle.load('assets/pin.png');
    Uint8List imagePixelData = Uint8List.view(fileData.buffer);
    MapImage _markerImage =
        MapImage.withPixelDataAndImageFormat(imagePixelData, ImageFormat.png);
    Anchor2D anchor2D = Anchor2D.withHorizontalAndVertical(0.5, 1);

    MapMarker mapMarker =
        MapMarker.withAnchor(_myPosition, _markerImage, anchor2D);
    mapMarker.drawOrder = 0;

    Metadata metadata = new Metadata();
    metadata.setString("key_poi", "Metadata: This is a POI.");
    mapMarker.metadata = metadata;

    _myHereMapController.mapScene.addMapMarker(mapMarker);
  }

  @override
  void initState() {
    _determinePosition();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: HereMap(
        onMapCreated: (HereMapController hereMapController) {
          hereMapController.mapScene.loadSceneForMapScheme(MapScheme.normalDay,
              (MapError error) {
            if (error == null) {
              _myHereMapController = hereMapController;
              const double distanceToEarthInMeters = 8000;
              hereMapController.camera.lookAtPointWithDistance(
                  GeoCoordinates(52.530932, 13.384915),
                  distanceToEarthInMeters);
            } else {
              print("Map scene not loaded. MapError: " + error.toString());
            }
          });
        },
      ),
    );
  }
}
