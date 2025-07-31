import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';

class CSVHelper {
  // Generate and save a CSV file
  static Future<String> saveToCSV({
    required List<List<String>> rows,
    required String fileName,
  }) async {
    // Get the application's document directory
    final directory = await getApplicationDocumentsDirectory();

    // Create file path
    final path = '${directory.path}/$fileName';

    // Create CSV content
    String csv = const ListToCsvConverter().convert(rows);

    // Write to file
    final file = File(path);
    await file.writeAsString(csv);

    return path;
  }
}
