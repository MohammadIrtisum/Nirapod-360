import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recording_controller.dart';

class RecordingView extends StatelessWidget {
  final RecordingController controller = Get.put(RecordingController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("HAR Recorder"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Label Input
            TextField(
              onChanged: controller.setLabel,
              decoration: const InputDecoration(labelText: "Activity Label"),
            ),
            const SizedBox(height: 20),

            // Save Button
            ElevatedButton(
              onPressed: () => controller.saveRecording("activity_data"),
              child: const Text("Save Recording"),
            ),
            const SizedBox(height: 20),

            // Data Display
            Expanded(
              child: Obx(() {
                return ListView(
                  children: [
                    const Text("Accelerometer Data:"),
                    Text(controller.accelerometerData.toString()),
                    const SizedBox(height: 20),
                    const Text("Gyroscope Data:"),
                    Text(controller.gyroscopeData.toString()),
                    const SizedBox(height: 20),
                    const Text("Linear Acceleration Data:"),
                    Text(controller.linearAccelerationData.toString()),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
