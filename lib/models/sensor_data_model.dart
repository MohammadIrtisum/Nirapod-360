// lib/models/sensor_data_model.dart
import 'package:flutter/foundation.dart'; // For debugPrint

class SensorDataModel {
  final List<String> _data = [];

  // --- THIS IS THE CRUCIAL GETTER ---
  List<String> get allData => List.unmodifiable(_data);
  // --- ENSURE IT LOOKS EXACTLY LIKE THIS ---

  void addData(String entry) {
    _data.add(entry);
    // debugPrint("SensorDataModel: Added: $entry");
  }

  void clearData() {
    _data.clear();
    // debugPrint("SensorDataModel: Data cleared.");
  }

  Future<String> saveToFile() async {
    if (_data.isEmpty) {
      // debugPrint("SensorDataModel: No data to save for saveToFile().");
      throw Exception("No data to save in SensorDataModel.");
    }
    await Future.delayed(const Duration(milliseconds: 50)); // Simulate save
    // debugPrint("SensorDataModel: Simulating save for ${_data.length} items.");
    return "simulated/path/sensor_data.txt";
  }
}