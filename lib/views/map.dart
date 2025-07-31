import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({super.key});

  @override
  State<CurrentLocationMap> createState() => _CurrentLocationMapState();
}

class _CurrentLocationMapState extends State<CurrentLocationMap> {
  LatLng? currentLocation;
  final MapController mapController = MapController();
  final LatLng startPoint = LatLng(23.8103, 90.4125);

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showDialog(
        title: "Location Service Disabled",
        message: "Please enable location services.",
        onSettingsPressed: Geolocator.openLocationSettings,
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _showDialog(
        title: "Permission Denied Forever",
        message: "Enable location permission from app settings.",
        onSettingsPressed: openAppSettings,
      );
      return;
    }

    if (permission == LocationPermission.denied) {
      _showDialog(
        title: "Permission Denied",
        message: "Location permission is required.",
      );
      return;
    }

    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      _showDialog(title: "Error", message: "Failed to get location: $e");
    }
  }

  void _showDialog({
    required String title,
    required String message,
    Future<void> Function()? onSettingsPressed,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          if (onSettingsPressed != null)
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                await onSettingsPressed();
              },
              child: const Text("Settings"),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _shareLocation() async { // Make it async
    if (currentLocation != null) {
      final latitude = currentLocation!.latitude;
      final longitude = currentLocation!.longitude;
      final googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
      final String shareText = 'Check out my location: $googleMapsUrl';
      try {
        await Share.share(shareText, subject: 'My Current Location'); // Added await and subject
        if (mounted) { // Good practice to check if widget is still in tree
          _showDialog( // Or use ScaffoldMessenger.of(context).showSnackBar
            title: "Shared",
            message: "Location shared successfully!",
          );
        }
      } catch (e) {
        print("Error sharing location: $e"); // VERY IMPORTANT: CHECK YOUR CONSOLE FOR THIS
        if (mounted) {
          _showDialog(
            title: "Sharing Error",
            message: "Could not share location: $e",
          );
        }
      }
    } else {
      if (mounted) {
        _showDialog(
            title: "Error",
            message: "Location not available to share."
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("Map with Current Location")),
      body: currentLocation == null
          ? const Center(child: CircularProgressIndicator())
          : Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentLocation!,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentLocation!,
                    width: 60,
                    height: 60,
                    child: const Icon(
                      Icons.location_pin,
                      color: Colors.red,
                      size: 40,
                    ),
                  ),
                ],
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: [startPoint, currentLocation!],
                    color: Colors.blueAccent,
                    strokeWidth: 4,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Column(
              children: [
                _mapButton(Icons.add, () {
                  mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom + 1,
                  );
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.remove, () {
                  mapController.move(
                    mapController.camera.center,
                    mapController.camera.zoom - 1,
                  );
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.my_location, () {
                  if (currentLocation != null) {
                    mapController.move(currentLocation!, 15);
                  }
                }),
                const SizedBox(height: 8),
                _mapButton(Icons.share, _shareLocation),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _mapButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton(
      heroTag: icon.toString(),
      mini: true,
      onPressed: onPressed,
      child: Icon(icon),
    );
  }
}
