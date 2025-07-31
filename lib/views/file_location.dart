import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';

import '../controllers/file_location_controller.dart';
import '../utils/animated_file_tile.dart';

class FileLocationView extends StatelessWidget {
  final FileLocationController controller = Get.put(FileLocationController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('File Location'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4E54C8), Color(0xFF8F94FB)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          if (controller.files.isEmpty) {
            return Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  controller.fetchFiles(); // Retry fetching files
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white.withOpacity(0.9),
                  foregroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: controller.files.length,
            itemBuilder: (context, index) {
              final filePath = controller.files[index];
              final fileName = filePath.split('/').last; // Extract file name

              return AnimatedFileTile(
                fileName: fileName,
                onTap: () {
                  controller.openFile(filePath); // Open file
                },
                onDelete: () {
                  _confirmDelete(context, filePath); // Confirm and delete file
                },
              );
            },
          );
        }),
      ),
    );
  }

  // Confirm deletion dialog
  void _confirmDelete(BuildContext context, String filePath) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete File'),
        content: const Text('Are you sure you want to delete this file?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteFile(filePath); // Call delete method
              Navigator.of(context).pop(); // Close dialog
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
