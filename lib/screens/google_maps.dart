import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMapsScreen> {
  final Set<Marker> _markers = {};
  final LatLng _currentPosition = const LatLng(-7.797068, 110.370529);
  GoogleMapController? _controller;
  Location currentLocation = Location();

  void getLocation() async {
    await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((LocationData loc) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
            zoom: 14,
          ),
        ),
      );
      // setState(() {
      //   _markers.add(
      //     Marker(
      //       markerId: const MarkerId("Your Location"),
      //       position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
      //     ),
      //   );
      // });
    });
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      getLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps on Flutter"),
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 14.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _controller = controller;
          },
          markers: _markers,
          myLocationButtonEnabled: true,
          myLocationEnabled: true,
          onTap: (position) {
            setState(
              () {
                _markers.add(
                  Marker(
                    markerId:
                        MarkerId("${position.latitude}, ${position.longitude}"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: position,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
