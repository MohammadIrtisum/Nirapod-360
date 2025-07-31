import 'dart:async';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sensors_plus/sensors_plus.dart';

class HARController extends GetxController {
  var isRecording = false.obs;
  var selectedLabel = 'Choose label'.obs;
  var accelerometerData = <String>[].obs;
  var gyroscopeData = <String>[].obs;
  var labels = ['Running', 'Standing', 'Sitting', 'Walking'].obs;
  var status = 'Idle'.obs;

  late StreamSubscription accelerometerStream;
  late StreamSubscription gyroscopeStream;

  @override
  void onInit() {
    super.onInit();
    checkPermissions();
  }

  Future<void> checkPermissions() async {
    if (await Permission.storage.isDenied) {
      await Permission.storage.request();
    }
  }

  void startRecording() {
    if (selectedLabel.value == 'Choose label') {
      Get.snackbar('Error', 'Please select a label to start recording!');
      return;
    }

    isRecording.value = true;
    status.value = "Recording...";

    accelerometerStream = accelerometerEvents.listen((event) {
      accelerometerData.add('X: ${event.x}, Y: ${event.y}, Z: ${event.z}');
    });

    gyroscopeStream = gyroscopeEvents.listen((event) {
      gyroscopeData.add('X: ${event.x}, Y: ${event.y}, Z: ${event.z}');
    });
  }

  void stopRecording() {
    isRecording.value = false;
    status.value = "Stopped";

    accelerometerStream.cancel();
    gyroscopeStream.cancel();

    saveDataToStorage();
  }

  Future<void> saveDataToStorage() async {
    // Implement storage logic here
    print("Accelerometer Data: ${accelerometerData.length} entries");
    print("Gyroscope Data: ${gyroscopeData.length} entries");
  }

  void addLabel(String label) {
    labels.add(label);
  }
}
