// lib/views/dialogs/add_label_dialog.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/main_controller.dart'; // Ensure this path is correct

class AddLabelDialog extends StatelessWidget {
  // Removed constructor argument: const AddLabelDialog({super.key, required this.controller});
  AddLabelDialog({super.key}); // Added super.key

  final MainController controller = Get.find(); // Get controller instance

  @override
  Widget build(BuildContext context) {
    final TextEditingController labelController = TextEditingController();

    return AlertDialog(
      title: const Text('Add New Label'), // Simpler title
      content: TextField(
        controller: labelController,
        autofocus: true, // Good to add for better UX
        decoration: const InputDecoration(
          hintText: 'Enter label name',
          // You could add more styling from your original MainActivity version if desired
          // e.g., border, prefixIcon
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            String newLabel = labelController.text.trim();
            if (newLabel.isNotEmpty) {
              // --- Enhancements from your original logic (Optional, but recommended) ---
              if (!controller.labels.map((l) => l.toLowerCase()).contains(newLabel.toLowerCase())) {
                controller.labels.add(newLabel);
                // To make the experience better, you might want to also select it:
                // controller.selectedLabel.value = newLabel;
                Get.back(); // Close dialog
                Get.snackbar('Success', 'Label "$newLabel" added.',
                    backgroundColor: Colors.green.shade600, colorText: Colors.white);
              } else {
                // Don't close dialog, let user correct
                Get.snackbar('Info', 'Label "$newLabel" already exists.',
                    backgroundColor: Colors.orange.shade600, colorText: Colors.white);
              }
              // --- End Enhancements ---
            } else {
              // Don't close dialog for empty label
              Get.snackbar('Error', 'Label name cannot be empty.',
                  backgroundColor: Theme.of(context).colorScheme.error, colorText: Colors.white);
            }
          },
          child: const Text('Add'),
        ),
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}