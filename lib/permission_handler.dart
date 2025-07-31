import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  // Request permissions for Android
  if (await Permission.camera.request().isGranted) {
    // Camera permission granted
  } else {
    // Handle permission denied
  }

  if (await Permission.location.request().isGranted) {
    // Location permission granted
  } else {
    // Handle permission denied
  }

  // Check storage permissions if needed
  if (await Permission.storage.request().isGranted) {
    // Storage permission granted
  } else {
    // Handle permission denied
  }
}
