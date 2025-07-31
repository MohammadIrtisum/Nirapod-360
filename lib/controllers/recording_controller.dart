import 'package:get/get.dart';
import '../models/recording_model.dart';
import '../services/recording_service.dart';

class RecordingController extends GetxController {
  final RecordingService _service = RecordingService();

  var accelerometerData = <List<double>>[].obs;
  var gyroscopeData = <List<double>>[].obs;
  var linearAccelerationData = <List<double>>[].obs;
  var label = ''.obs;

  Future<void> saveRecording(String filename) async {
    if (label.value.isEmpty) {
      Get.snackbar("Error", "Please set a label before saving.");
      return;
    }

    final recording = RecordingModel(
      accelerometerData: accelerometerData,
      gyroscopeData: gyroscopeData,
      linearAccelerationData: linearAccelerationData,
      label: label.value,
    );

    try {
      final path = await _service.saveData(filename, recording);
      Get.snackbar("Success", "Data saved at: $path");
    } catch (e) {
      Get.snackbar("Error", e.toString());
    }
  }

  void setLabel(String newLabel) {
    label.value = newLabel;
  }
}
