import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class FileHelper {
  static Future<String> getFilePath() async {
    final directory = await getApplicationDocumentsDirectory();
    return "${directory.path}/sensor_data.csv";
  }

  static Future<void> saveDataToCSV(List<List<dynamic>> data) async {
    String filePath = await getFilePath();
    File file = File(filePath);

    String csvData = const ListToCsvConverter().convert(data);

    // Write or append the data to the CSV file
    if (file.existsSync()) {
      await file.writeAsString(csvData, mode: FileMode.append);
    } else {
      await file.writeAsString(csvData);
    }
  }
}
