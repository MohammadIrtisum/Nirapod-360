import 'dart:io';
import 'package:get/get.dart';
import 'package:open_file/open_file.dart';
import 'package:permission_handler/permission_handler.dart';

class FileLocationController extends GetxController {
  var files = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchFiles();
  }

  Future<void> fetchFiles() async {
    try {
      // Check permissions
      if (!await Permission.storage.isGranted) {
        await Permission.storage.request();
        if (!await Permission.storage.isGranted) {
          files.value = ['Storage permission denied.'];
          return;
        }
      }

      // Folder path
      final appFolder = Directory('/storage/emulated/0/HAR Recorder');
      print("Fetching files from: ${appFolder.path}");

      if (!await appFolder.exists()) {
        print("Folder does not exist.");
        files.value = ['No files found.'];
        return;
      }

      // Fetch files
      final fileList = appFolder.listSync().whereType<File>().toList();
      if (fileList.isEmpty) {
        files.value = ['No files found.'];
      } else {
        files.value = fileList.map((file) => file.path).toList();
      }

      print("Files found: ${files.value}");
    } catch (e) {
      files.value = ['Error: Unable to fetch files.'];
      print("Error fetching files: $e");
    }
  }

  Future<void> openFile(String filePath) async {
    try {
      final result = await OpenFile.open(filePath);
      if (result.type != ResultType.done) {
        Get.snackbar('Error', 'Could not open file.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to open file: $e');
    }
  }
  Future<void> deleteFile(String filePath) async {
    try {
      // Check if the file exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete(); // Delete the file
        files.remove(filePath); // Remove the file path from the list
        Get.snackbar('Success', 'File deleted successfully!');
      } else {
        Get.snackbar('Error', 'File does not exist.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete file: $e');
    }
  }
}
