// ../views/prediction_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart'; // Ensure this path is correct

class PredictionView extends StatelessWidget {
  final MainController controller;

  const PredictionView({super.key, required this.controller});

  static const Color backgroundColor = Color(0xFFF0F4F8);
  static const Color cardBackgroundColor = Colors.white;
  static const Color recordingColor = Colors.redAccent;
  static const Color dangerDetectedColor = Colors.red; // Specific for DANGER state
  static const Color abnormalActivityColor = Color(0xFFFF9800); // Orange for general abnormal
  static const Color normalActivityColor = Color(0xFF4CAF50); // Green for normal
  static const Color statusInfoColor = Color(0xFF00796B); // Teal for general info
  static const Color statusWarningColor = Color(0xFFFFA000); // Amber for warnings
  static const Color statusErrorColor = Color(0xFFD32F2F); // Red for errors
  static const Color statusNeutralColor = Color(0xFF546E7A); // BlueGrey for idle/paused


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildOverallStatusCard(controller), // Renamed for clarity
              const SizedBox(height: 16),
              _buildSectionTitle("Real-time Prediction & Danger Status"),
              _buildPredictionAndDangerCard(controller), // Renamed for clarity
              const SizedBox(height: 16),
              _buildSectionTitle("Current Activity Details"),
              _buildActivityDetailsCard(controller), // New card for clarity
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 12.0, bottom: 6.0, left: 4.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Colors.teal.shade800, // Darker teal
          letterSpacing: 0.8,
        ),
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, Color color, String text, {FontWeight fontWeight = FontWeight.w500, double fontSize = 15}) {
    return Row(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize, fontWeight: fontWeight, color: color),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }

  // Card for overall API and recording status
  Widget _buildOverallStatusCard(MainController controller) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: cardBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() {
          String apiStatusText = "API: Initializing...";
          IconData apiIcon = Icons.cloud_sync_outlined;
          Color apiColor = statusNeutralColor;

          String recordingStatusText = controller.isRecording.value
              ? controller.status.value // e.g., "Recording: Jumping"
              : "Data Collection: INACTIVE";
          IconData recordingIcon = controller.isRecording.value ? Icons.sensors_rounded : Icons.sensors_off_rounded;
          Color recordingStatusDisplayColor = controller.isRecording.value ? recordingColor : statusNeutralColor;


          // Determine API status based on currentPrediction
          final currentPred = controller.currentPrediction.value;
          if (currentPred.startsWith("Activity:") || currentPred.contains("Awaiting sensor data")) {
            apiStatusText = "API: Receiving Data";
            apiIcon = Icons.rss_feed_rounded;
            apiColor = statusInfoColor;
          } else if (currentPred.contains("Prediction API Ready")) {
            apiStatusText = "API: Connected & Ready";
            apiIcon = Icons.power_rounded;
            apiColor = normalActivityColor;
          } else if (currentPred.contains("Calling API")) {
            apiStatusText = "API: Fetching Prediction...";
            apiIcon = Icons.cloud_upload_outlined;
            apiColor = statusWarningColor;
          } else if (currentPred.contains("Timeout")) {
            apiStatusText = "API: Connection Timeout";
            apiIcon = Icons.timer_off_outlined;
            apiColor = statusErrorColor;
          } else if (currentPred.contains("Error") || currentPred.contains("Mismatch") || currentPred.contains("Resp Fmt Err")) {
            apiStatusText = "API: Error Occurred";
            apiIcon = Icons.error_outline_rounded;
            apiColor = statusErrorColor;
            if (currentPred.contains("Scaler Config Error")) apiStatusText = "API: Scaler Config Error!";
            else if (currentPred.contains("Feature Count Error")) apiStatusText = "API: Feature Count Error!";

          } else if (currentPred.contains("Prediction Service Idle")){
            apiStatusText = "API: Service Idle";
            apiIcon = Icons.pause_circle_outline_rounded;
            apiColor = statusNeutralColor;
          } else if (currentPred.contains("Recording Paused. API Ready.")) {
            apiStatusText = "API: Connected & Ready";
            apiIcon = Icons.power_rounded;
            apiColor = normalActivityColor;
          }


          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusRow(apiIcon, apiColor, apiStatusText, fontWeight: FontWeight.w600),
              const SizedBox(height: 12),
              _buildStatusRow(recordingIcon, recordingStatusDisplayColor, recordingStatusText),
            ],
          );
        }),
      ),
    );
  }


  // Card for Prediction string (abnormal/normal based on string) and Danger status
  Widget _buildPredictionAndDangerCard(MainController controller) {
    return Obx(() {
      Color currentCardBg = cardBackgroundColor;
      BorderSide cardBorderSide = BorderSide.none;

      String mainStatusText = "Awaiting Data...";
      IconData mainStatusIcon = Icons.hourglass_empty_rounded;
      Color mainStatusColor = statusNeutralColor;
      FontWeight mainFontWeight = FontWeight.w600;


      if (controller.isDangerDetected.value) {
        currentCardBg = dangerDetectedColor.withOpacity(0.1);
        cardBorderSide = BorderSide(color: dangerDetectedColor, width: 2.0);
        mainStatusText = "DANGER DETECTED!";
        mainStatusIcon = Icons.report_problem_rounded;
        mainStatusColor = dangerDetectedColor;
      } else if (controller.isRecording.value) {
        if (controller.currentPrediction.value.startsWith("Activity:")) {
          if (controller.isAbnormal.value) {
            mainStatusText = "Abnormal Activity Detected";
            mainStatusIcon = Icons.warning_amber_rounded;
            mainStatusColor = abnormalActivityColor;
            currentCardBg = abnormalActivityColor.withOpacity(0.08);
          } else {
            mainStatusText = "Normal Activity Detected";
            mainStatusIcon = Icons.check_circle_outline_rounded;
            mainStatusColor = normalActivityColor;
            currentCardBg = normalActivityColor.withOpacity(0.08);
          }
        } else if (controller.currentPrediction.value.contains("Error") ||
            controller.currentPrediction.value.contains("Timeout") ||
            controller.currentPrediction.value.contains("Mismatch")) {
          mainStatusText = controller.currentPrediction.value; // Show the error
          mainStatusIcon = Icons.error_outline;
          mainStatusColor = statusErrorColor;
          currentCardBg = statusErrorColor.withOpacity(0.08);
        }
        else { // Waiting for data, calling API, etc.
          mainStatusText = "Analyzing Activity...";
          mainStatusIcon = Icons.youtube_searched_for_rounded; // More active waiting icon
          mainStatusColor = statusInfoColor;
        }
      } else { // Not recording
        mainStatusText = "Prediction Paused";
        mainStatusIcon = Icons.pause_circle_filled_rounded;
        mainStatusColor = statusNeutralColor;
        String lastPred = controller.currentPrediction.value;
        if (lastPred.startsWith("Activity:")) {
          String lastActivity = lastPred.substring("Activity: ".length).trim();
          mainStatusText = "Last: $lastActivity (Paused)";
        } else if (lastPred.contains("Prediction API Ready")) {
          mainStatusText = "Prediction Ready (Paused)";
        }
      }


      return Card(
        elevation: 2.0,
        color: currentCardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
          side: cardBorderSide,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: _buildStatusRow(mainStatusIcon, mainStatusColor, mainStatusText, fontWeight: mainFontWeight, fontSize: 16),
        ),
      );
    });
  }

  // Card for displaying the specific activity string
  Widget _buildActivityDetailsCard(MainController controller) {
    return Obx(() {
      final predictionText = controller.currentPrediction.value;
      String activityName = "---";
      Color activityColor = statusNeutralColor;
      IconData activityIcon = Icons.help_outline_rounded;


      if (controller.isRecording.value && predictionText.startsWith("Activity: ")) {
        activityName = predictionText.substring("Activity: ".length).trim();
        // You can map activity names to specific icons and colors if you want
        // For now, use a generic icon and color based on abnormal/normal status
        if(controller.isAbnormal.value) {
          activityIcon = Icons.directions_walk_rounded; // Example, change as needed
          activityColor = abnormalActivityColor;
        } else {
          activityIcon = Icons.accessibility_new_rounded; // Example
          activityColor = normalActivityColor;
        }

        // Specific icons (example - expand this map)
        const activityIconMap = {
          "Running": Icons.directions_run_rounded,
          "Walking": Icons.directions_walk_rounded,
          "Sitting": Icons.airline_seat_recline_normal_rounded,
          "Standing": Icons.accessibility_rounded,
          "Jumping": Icons.sports_gymnastics_rounded,
          "Falling_down": Icons.personal_injury_outlined,
          "Stambling": Icons.skateboarding_rounded, // Just an example, pick better icons
          "Kicking": Icons.sports_soccer_outlined,
          "Punching": Icons.sports_kabaddi_rounded,
          "Pushing": Icons.pan_tool_alt_outlined,
          "Climbing_Up": Icons.stairs_outlined,
          "Climbing_Down": Icons.elevator_outlined,
        };
        if (activityIconMap.containsKey(activityName)) {
          activityIcon = activityIconMap[activityName]!;
        }

      } else if (!controller.isRecording.value) {
        activityName = "(Paused)";
        activityIcon = Icons.pause_rounded;
      } else if (predictionText.contains("Awaiting")){
        activityName = "(Awaiting Data)";
        activityIcon = Icons.update_rounded;
      } else if (predictionText.contains("Error") || predictionText.contains("Timeout")){
        activityName = "(Prediction Error)";
        activityIcon = Icons.signal_wifi_connected_no_internet_4_rounded;
      }


      return Card(
        elevation: 2.0,
        color: cardBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
          child: _buildStatusRow(activityIcon, activityColor.withOpacity(0.8), activityName, fontWeight: FontWeight.bold, fontSize: 17),
        ),
      );
    });
  }

// This helper is no longer strictly needed if we rely on currentPrediction content for status.
// bool _isModelStillLoading(MainController controller) {
//   final value = controller.currentPrediction.value;
//   return value.contains("Service Idle") || value.contains("Error!"); // Updated logic
// }
}