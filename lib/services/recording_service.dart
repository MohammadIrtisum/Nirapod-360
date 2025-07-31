import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/recording_model.dart';

class RecordingService {
  Future<String> saveData(String filename, RecordingModel recording) async {
    // Request storage permission
    if (await Permission.storage.request().isDenied) {
      throw Exception("Storage permission denied");
    }

    // Get app directory for storage
    final directory = await getApplicationDocumentsDirectory();
    final outputDir = Directory('${directory.path}/HAR_Recordings');
    if (!await outputDir.exists()) {
      await outputDir.create(recursive: true);
    }

    final outputFile = File('${outputDir.path}/$filename.csv');

    // Synchronize data sizes
    final minLength = [
      recording.accelerometerData.length,
      recording.gyroscopeData.length,
      recording.linearAccelerationData.length
    ].reduce((a, b) => a < b ? a : b);

    final accData = recording.accelerometerData.take(minLength).toList();
    final gyroData = recording.gyroscopeData.take(minLength).toList();
    final linearAccData = recording.linearAccelerationData.take(minLength).toList();

    // Prepare CSV content
    final csvBuffer = StringBuffer();
    csvBuffer.writeln(
        'acc_x,acc_y,acc_z,gyro_x,gyro_y,gyro_z,la_x,la_y,la_z,label');
    for (int i = 0; i < minLength; i++) {
      final accRow = accData[i].join(',');
      final gyroRow = gyroData[i].join(',');
      final laRow = linearAccData[i].join(',');
      csvBuffer.writeln('$accRow,$gyroRow,$laRow,${recording.label}');
    }

    // Save to file
    await outputFile.writeAsString(csvBuffer.toString());
    return outputFile.path;
  }
}
