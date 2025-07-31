class RecordingModel {
  final List<List<double>> accelerometerData;
  final List<List<double>> gyroscopeData;
  final List<List<double>> linearAccelerationData;
  final String label;

  RecordingModel({
    required this.accelerometerData,
    required this.gyroscopeData,
    required this.linearAccelerationData,
    required this.label,
  });
}
