// har_view_model.dart
import 'package:flutter/foundation.dart';
// DELETE THE NEXT LINE if it exists and you intend to use the one in /models
// import 'package:har_app2/sensor_data_model.dart';
import 'dart:math'; // For random prediction simulation
import 'package:har_app2/models/sensor_data_model.dart'; // THIS IS THE ONE TO KEEP if the file is in lib/models/

class HARViewModel with ChangeNotifier {
  final SensorDataModel _sensorDataModel = SensorDataModel();
  bool _isRecording = false;

  String _currentPrediction = "No Prediction Yet";
  bool _isDanger = false;

  // --- Getters for UI ---
  bool get isRecording => _isRecording;
  List<String> get sensorData => _sensorDataModel.allData;
  String get currentPrediction => _currentPrediction;
  bool get isDanger => _isDanger;

  // Simulates your ML model prediction
  // In a real app, this would take structured sensor data (e.g., List<List<double>>)
  // and return the model's output.
  Future<String> _predictActivityFromData(String singleDataPoint) async {
    // Simulate network delay or processing time
    await Future.delayed(const Duration(milliseconds: 100));

    // ---- THIS IS WHERE YOUR ACTUAL MODEL LOGIC WOULD GO ----
    // For now, let's simulate:
    // If the data contains "fall", "impact", or "erratic", it's abnormal.
    // Otherwise, randomly pick a normal activity.
    final dataLowerCase = singleDataPoint.toLowerCase();
    if (dataLowerCase.contains("Fall_down") ||
        dataLowerCase.contains("running") ||
        dataLowerCase.contains("kicking") ||
        dataLowerCase.contains("pushing")) { // Add a specific trigger for testing
      return "Abnormal Activity";
    } else {
      List<String> normalActivities = ["Walking", "Sitting", "Standing"];
      return normalActivities[Random().nextInt(normalActivities.length)];
    }
    // ---- END OF SIMULATED MODEL LOGIC ----
  }

  /// Updates the prediction and danger status based on the model output.
  Future<void> _updatePrediction(String rawSensorData) async {
    if (!_isRecording) { // Only predict if recording
      _currentPrediction = "Not Recording";
      _isDanger = false;
      notifyListeners();
      return;
    }

    _currentPrediction = "Predicting..."; // Show intermediate state
    notifyListeners();

    String predictionResult = await _predictActivityFromData(rawSensorData);
    _currentPrediction = predictionResult;

    if (predictionResult.toLowerCase().contains("abnormal")) {
      _isDanger = true;
    } else {
      _isDanger = false;
    }
    print("HARViewModel: Prediction: $_currentPrediction, Danger: $_isDanger");
    notifyListeners();
  }

  void startRecording() {
    if (_isRecording) return;

    _sensorDataModel.clearData();
    _isRecording = true;
    _currentPrediction = "Awaiting Data...";
    _isDanger = false;
    notifyListeners();
    print("HARViewModel: Recording started.");
  }

  void stopRecording() {
    if (!_isRecording) return;

    _isRecording = false;
    _currentPrediction = "Recording Stopped";
    // _isDanger = false; // Keep last danger state or reset? Let's reset for clarity.
    _isDanger = false;
    notifyListeners();
    print("HARViewModel: Recording stopped.");
  }

  /// Adds a sensor data point and triggers a prediction.
  void addSensorData(String data) {
    _sensorDataModel.addData(data);
    // When data is added, immediately try to get a prediction
    // In a real app, you might collect a "window" of data before predicting
    _updatePrediction(data); // Pass the latest data point for prediction
    // No need to call notifyListeners() here if _updatePrediction already does.
    print("HARViewModel: Sensor data added: $data");
  }

  Future<String?> saveDataToFile() async {
    if (_sensorDataModel.allData.isEmpty) {
      print("HARViewModel: No data to save.");
      return null;
    }
    try {
      final filePath = await _sensorDataModel.saveToFile();
      print("HARViewModel: Data saved to $filePath");
      return filePath;
    } catch (e) {
      print("HARViewModel: Error saving data to file - $e");
      return null;
    }
  }

  void clearSensorData() {
    _sensorDataModel.clearData();
    _currentPrediction = "Data Cleared";
    _isDanger = false;
    notifyListeners();
    print("HARViewModel: All sensor data cleared explicitly.");
  }
}