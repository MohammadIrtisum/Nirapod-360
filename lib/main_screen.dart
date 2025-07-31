import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'har_view_model.dart'; // Make sure this import is correct

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.blueGrey.shade700;
    final Color accentColor = Colors.tealAccent.shade400;
    final Color backgroundColor = Colors.grey.shade100;
    final Color cardColor = Colors.white;
    final Color textColor = Colors.grey.shade800;
    final Color recordingColor = Colors.red.shade600;
    final Color dangerColor = Colors.red.shade800;
    final Color predictionTextColor = Colors.blue.shade700;

    return ChangeNotifierProvider(
      create: (context) => HARViewModel(),
      child: Scaffold(
        backgroundColor: backgroundColor,
        appBar: AppBar(
          title: const Text(
            'HAR Activity Monitor', // Updated title
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
          backgroundColor: primaryColor,
          elevation: 4.0,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Consumer<HARViewModel>(
          builder: (context, harViewModel, child) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Card(
                  elevation: 8.0,
                  color: cardColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.0),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // -- DANGER ALERT --
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: FadeTransition(opacity: animation, child: child),
                            );
                          },
                          child: harViewModel.isDanger
                              ? Container(
                            key: const ValueKey('danger_alert'), // Key for animation
                            margin: const EdgeInsets.only(bottom: 20.0),
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              color: dangerColor,
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: dangerColor.withOpacity(0.5),
                                  spreadRadius: 2,
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                                SizedBox(width: 10),
                                Text(
                                  'DANGER DETECTED!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : const SizedBox(key: ValueKey('no_danger_alert')), // Empty SizedBox when no danger
                        ),

                        // -- STATUS TEXT AND ICON --
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              transitionBuilder: (Widget child, Animation<double> animation) {
                                return FadeTransition(opacity: animation, child: ScaleTransition(scale: animation, child: child));
                              },
                              child: Icon(
                                harViewModel.isRecording
                                    ? Icons.fiber_manual_record_rounded
                                    : Icons.play_circle_outline_rounded,
                                key: ValueKey<bool>(harViewModel.isRecording),
                                color: harViewModel.isRecording ? recordingColor : primaryColor,
                                size: 30,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded( // Allow text to wrap
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  harViewModel.isRecording ? 'Recording...' : 'Ready to Record',
                                  key: ValueKey<String>(harViewModel.isRecording ? "status_recording" : "status_ready"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    color: harViewModel.isRecording ? recordingColor : textColor,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // -- PREDICTION DISPLAY --
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.insights_rounded, color: predictionTextColor.withOpacity(0.8), size:20),
                              SizedBox(width: 8),
                              Flexible( // Handles long prediction strings
                                child: Text(
                                  'Activity: ${harViewModel.currentPrediction}',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: predictionTextColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),


                        // -- START/STOP BUTTON --
                        ElevatedButton.icon(
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            transitionBuilder: (Widget child, Animation<double> animation) {
                              return ScaleTransition(scale: animation, child: child);
                            },
                            child: Icon(
                              harViewModel.isRecording ? Icons.stop_rounded : Icons.play_arrow_rounded,
                              key: ValueKey<bool>(harViewModel.isRecording),
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                          label: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              harViewModel.isRecording ? 'Stop' : 'Start',
                              key: ValueKey<String>(harViewModel.isRecording ? "btn_stop" : "btn_start"),
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: harViewModel.isRecording ? recordingColor : primaryColor,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            minimumSize: const Size(180, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 5,
                          ),
                          onPressed: () {
                            if (harViewModel.isRecording) {
                              harViewModel.stopRecording();
                              harViewModel.saveDataToFile().then((filePath) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(filePath != null ? 'Data saved to $filePath' : 'No data was saved.'),
                                      backgroundColor: filePath != null ? Colors.green.shade700 : Colors.orange.shade700,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                      margin: const EdgeInsets.all(10),
                                    ),
                                  );
                                }
                              });
                            } else {
                              harViewModel.startRecording();
                            }
                          },
                        ),
                        const SizedBox(height: 20),

                        // -- ADD MOCK DATA BUTTON --
                        OutlinedButton.icon(
                          icon: Icon(Icons.biotech_outlined, color: accentColor, size: 22), // biotech is good for "test data"
                          label: Text(
                              'Add Mock Sensor Data',
                              style: TextStyle(color: accentColor.withBlue(150), fontWeight: FontWeight.w500)
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: accentColor.withOpacity(0.8), width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            minimumSize: const Size(180, 45),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          onPressed: () {
                            // For testing abnormal, add a special string
                            final mockDataOptions = [
                              "Normal Sensor Reading Alpha",
                              "Normal Sensor Reading Beta",
                              "Sample of steady movement",
                              "Abnormal_Sample Data Trigger" // This will trigger danger in our mock
                            ];
                            final randomMockData = mockDataOptions[Random().nextInt(mockDataOptions.length)];
                            harViewModel.addSensorData(randomMockData);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Mock data added: "${randomMockData.substring(0,min(randomMockData.length, 20))}..."'),
                                  backgroundColor: accentColor.withOpacity(0.9),
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  margin: const EdgeInsets.all(10),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}