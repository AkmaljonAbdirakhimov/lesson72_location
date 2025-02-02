import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lesson72_location/services/location_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(45.521563, -122.677433);
  final LatLng najotTalim = const LatLng(41.2856806, 69.2034646);
  LatLng myCurrentPosition = LatLng(41.2856806, 69.2034646);
  Set<Marker> myMarkers = {};
  Set<Polyline> polylines = {};
  List<LatLng> myPositions = [];

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration.zero, () async {
      await LocationService.getCurrentLocation();
      setState(() {});
      // watchMyLocation();
    });
  }

  void onCameraMove(CameraPosition position) {
    setState(() {
      myCurrentPosition = position.target;
    });
  }

  void watchMyLocation() {
    LocationService.getLiveLocation().listen((location) {
      print("Live location: $location");
    });
  }

  void addLocationMarker() {
    myMarkers.add(
      Marker(
        markerId: MarkerId(myMarkers.length.toString()),
        position: myCurrentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
      ),
    );

    myPositions.add(myCurrentPosition);

    if (myPositions.length == 2) {
      LocationService.fetchPolylinePoints(
        myPositions[0],
        myPositions[1],
      ).then((List<LatLng> positions) {
        polylines.add(
          Polyline(
            polylineId: PolylineId(UniqueKey().toString()),
            color: Colors.blue,
            width: 5,
            points: positions,
          ),
        );

        // setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final myLocation = LocationService.currentLocation;

    print("CurrentLocation: $myLocation");

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              mapController.animateCamera(
                CameraUpdate.zoomOut(),
              );
            },
            icon: Icon(Icons.remove_circle),
          ),
          IconButton(
            onPressed: () {
              mapController.animateCamera(
                CameraUpdate.zoomIn(),
              );
            },
            icon: Icon(Icons.add_circle),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            buildingsEnabled: true,
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(
              target: najotTalim,
              zoom: 16.0,
            ),
            trafficEnabled: true,
            onCameraMove: onCameraMove,
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: {
              Marker(
                markerId: const MarkerId("najotTalim"),
                icon: BitmapDescriptor.defaultMarker,
                position: najotTalim,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              Marker(
                markerId: const MarkerId("myCurrentPosition"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                position: myCurrentPosition,
                infoWindow: const InfoWindow(
                  title: "Najot Ta'lim",
                  snippet: "Xush kelibsiz",
                ),
              ),
              ...myMarkers,
            },
            polylines: polylines,
          ),
          // const Align(
          //   child: Icon(
          //     Icons.place,
          //     color: Colors.blue,
          //     size: 60,
          //   ),
          // ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
      floatingActionButton: FloatingActionButton(
        onPressed: addLocationMarker,
        child: const Icon(Icons.add),
      ),
    );
  }
}
