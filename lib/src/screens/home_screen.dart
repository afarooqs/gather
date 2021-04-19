import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:places_autocomplete/src/blocs/application_bloc.dart';
import 'package:places_autocomplete/src/models/place.dart';
import 'package:provider/provider.dart';
import 'package:places_autocomplete/video.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Completer<GoogleMapController> _mapController = Completer();
  StreamSubscription locationSubscription;
  StreamSubscription boundsSubscription;
  final _locationController = TextEditingController();

  @override
  void initState() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);

    //Listen for selected Location
    locationSubscription =
        applicationBloc.selectedLocation.stream.listen((place) {
      if (place != null) {
        _locationController.text = place.name;
        _goToPlace(place);
      } else
        _locationController.text = "";
    });

    applicationBloc.bounds.stream.listen((bounds) async {
      final GoogleMapController controller = await _mapController.future;
      controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 50));
    });
    super.initState();
  }

  @override
  void dispose() {
    final applicationBloc =
        Provider.of<ApplicationBloc>(context, listen: false);
    applicationBloc.dispose();
    _locationController.dispose();
    locationSubscription.cancel();
    boundsSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final applicationBloc = Provider.of<ApplicationBloc>(context);
    return Scaffold(
        body: (applicationBloc.currentLocation == null)
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _locationController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        hintText: 'Search by City',
                        suffixIcon: Icon(Icons.search),
                      ),
                      onChanged: (value) => applicationBloc.searchPlaces(value),
                      onTap: () => applicationBloc.clearSelectedLocation(),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        height: 300.0,
                        child: GoogleMap(
                          mapType: MapType.normal,
                          myLocationEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(40.730166, -73.9980533),
                            zoom: 16,
                          ),
                          onMapCreated: (GoogleMapController controller) {
                            _mapController.complete(controller);
                          },
                          markers: Set<Marker>.of(applicationBloc.markers),
                        ),
                      ),
                      if (applicationBloc.searchResults != null &&
                          applicationBloc.searchResults.length != 0)
                        Container(
                            height: 300.0,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(.6),
                                backgroundBlendMode: BlendMode.darken)),
                      if (applicationBloc.searchResults != null)
                        Container(
                          height: 300.0,
                          child: ListView.builder(
                              itemCount: applicationBloc.searchResults.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(
                                    applicationBloc
                                        .searchResults[index].description,
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onTap: () {
                                    applicationBloc.setSelectedLocation(
                                        applicationBloc
                                            .searchResults[index].placeId);
                                  },
                                );
                              }),
                        ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Find Nearest',
                        style: TextStyle(
                            fontSize: 25.0, fontWeight: FontWeight.bold)),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Wrap(
                      spacing: 8.0,
                      children: [
                        FilterChip(
                          label: Text('Church'),
                          onSelected: (val) =>
                              applicationBloc.togglePlaceType('church', val),
                          selected: applicationBloc.placeType == 'church',
                          selectedColor: Colors.blueGrey,
                        ),
                        FilterChip(
                            label: Text('Mosque'),
                            onSelected: (val) =>
                                applicationBloc.togglePlaceType('mosque', val),
                            selected: applicationBloc.placeType == 'mosque',
                            selectedColor: Colors.green),
                        FilterChip(
                            label: Text('Temple'),
                            onSelected: (val) =>
                                applicationBloc.togglePlaceType('temple', val),
                            selected: applicationBloc.placeType == 'temple',
                            selectedColor: Colors.yellowAccent),
                      ],
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(
                        child: Text('Join a Prayer Meeting'),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => VideoPage()),
                          );
                        },
                      )),
                ],
              ));
  }

  Future<void> _goToPlace(Place place) async {
    final GoogleMapController controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
            target: LatLng(
                place.geometry.location.lat, place.geometry.location.lng),
            zoom: 14.0),
      ),
    );
  }

  Widget _wrapWithBanner(Widget child) {
    return Banner(
      child: child,
      location: BannerLocation.topStart,
      message: 'BETA',
      color: Colors.green.withOpacity(0.6),
      textStyle: TextStyle(
          fontWeight: FontWeight.w700, fontSize: 12.0, letterSpacing: 1.0),
      textDirection: TextDirection.ltr,
    );
  }
}
