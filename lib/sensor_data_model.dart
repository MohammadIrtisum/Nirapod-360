import 'dart:io';

import 'package:path_provider/path_provider.dart';

class SensorDataModel {
  List<String> _sensorData = [];

  // Add sensor data to the list
  void addData(String data) {
    _sensorData.add(data);
  }

  // Save sensor data to a file
  Future<String> saveToFile() async {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = '${directory.path}/sensor_data.txt';
    final file = File(filePath);

    // Write sensor data to file
    await file.writeAsString(_sensorData.join('\n'));

    return filePath;
  }
}
