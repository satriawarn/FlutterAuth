import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutterauth/utils/snack_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as lokasi;

class GoogleMapsScreen extends StatefulWidget {
  const GoogleMapsScreen({Key? key}) : super(key: key);

  @override
  State<GoogleMapsScreen> createState() => _GoogleMapsState();
}

class _GoogleMapsState extends State<GoogleMapsScreen> {
  final Set<Marker> _markers = {};
  final LatLng _currentPosition = const LatLng(-7.797068, 110.370529);
  GoogleMapController? _controller;
  lokasi.Location currentLocation = lokasi.Location();
  String? _address;

  void getLocation() async {
    await currentLocation.getLocation();
    currentLocation.onLocationChanged.listen((lokasi.LocationData loc) {
      _controller?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
            zoom: 14,
          ),
        ),
      );
      // getAddressLocation(loc.latitude!, loc.longitude!);
      // openSnackBar(context, "Your address is $_address", Colors.blue);
      // setState(() {
      //   getAddressLocation(loc.latitude!, loc.longitude!);
      //   _markers.add(
      //     Marker(
      //       markerId: const MarkerId("Your Location"),
      //       position: LatLng(loc.latitude ?? 0.0, loc.longitude ?? 0.0),
      //       infoWindow: InfoWindow(
      //         title: "Address",
      //         snippet: _address,
      //       ),
      //     ),
      //   );
      // });
    });
  }

  Future<void> getAddressLocation(double lat, double long) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);

    Placemark placeMark = placemarks[0];
    String? name = placeMark.name;
    String? subLocality = placeMark.subLocality;
    String? locality = placeMark.locality;
    String? administrativeArea = placeMark.administrativeArea;
    String? postalCode = placeMark.postalCode;
    String? country = placeMark.country;
    String? address =
        "$name, $subLocality, $locality, $administrativeArea $postalCode, $country";

    print("ikilho $name");

    setState(() {
      _address = address;
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
            getAddressLocation(position.latitude, position.longitude);
            setState(
              () {
                _markers.add(
                  Marker(
                    markerId:
                        MarkerId("${position.latitude}, ${position.longitude}"),
                    icon: BitmapDescriptor.defaultMarker,
                    position: position,
                    infoWindow: InfoWindow(
                      title: "Address",
                      snippet: _address,
                    ),
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
