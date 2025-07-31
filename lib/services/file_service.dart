import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

class FileService {
  /// Get the application's documents directory
  Future<String> _getDocumentsDirectory() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  /// Save sensor data to a CSV file
  Future<void> saveSensorDataToCSV({
    required List<List<String>> data,
    required String fileName,
  }) async {
    try {
      // Convert data to CSV format
      String csvData = const ListToCsvConverter().convert(data);

      // Get file path
      String directory = await _getDocumentsDirectory();
      String filePath = "$directory/$fileName.csv";

      // Write CSV data to file
      File file = File(filePath);
      await file.writeAsString(csvData);

      print("Data saved to $filePath");
    } catch (e) {
      print("Error saving data to CSV: $e");
    }
  }
}
