// lib/views/data_recorder_view.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/main_controller.dart';

class DataRecorderView extends StatelessWidget {
  final MainController controller;

  const DataRecorderView({super.key, required this.controller});

  // ---- Consistent Black & Orange Theme ----
  static final Color primaryOrange = Color(0xFFF57C00);
  static final Color lightOrange = Color(0xFFFF9800);
  static final Color primaryBlack = Colors.black;
  static final Color sectionBackground = Color(0xFF1C1C1C);
  static final Color textOnBlack = Color(0xFFF57C00);
  static final Color textOnOrange = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryBlack,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildSensorStatusCard(controller),
              _buildSectionTitle("Configuration"),
              _buildConfigurationCard(controller),
              _buildSectionTitle("Live Raw Sensor Data"),
              _buildRawSensorDataCard(controller),
              const SizedBox(height: 100), // Space for FAB
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      // --- CORRECTED FLOATING ACTION BUTTON STRUCTURE ---
      floatingActionButton: Obx(
            () => AnimatedOpacity(
          opacity: controller.isPhoneReadyForRecording.value ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 300),
          child: InkWell(
            onTap: controller.isPhoneReadyForRecording.value
                ? (controller.isRecording.value
                ? controller.stopRecording
                : controller.startRecording)
                : () => Get.snackbar("Sensor Error",
                "Phone not ready. Check sensors/permissions.",
                snackPosition: SnackPosition.BOTTOM,
                backgroundColor: Colors.red.shade600,
                colorText: Colors.white,
                margin: const EdgeInsets.all(10),
                borderRadius: 8.0),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              height: 56,
              width: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: controller.isRecording.value
                      ? [Colors.red.shade600, Colors.red.shade800]
                      : [lightOrange, primaryOrange],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: (controller.isRecording.value
                        ? Colors.red
                        : primaryOrange)
                        .withOpacity(0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: Icon(
                      controller.isRecording.value
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      key: ValueKey<bool>(controller.isRecording.value),
                      color: controller.isRecording.value
                          ? Colors.white
                          : textOnOrange,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 8),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(opacity: animation, child: child);
                    },
                    child: Text(
                      controller.isRecording.value
                          ? 'Stop CSV Recording'
                          : 'Start CSV Recording',
                      key: ValueKey<bool>(controller.isRecording.value),
                      style: GoogleFonts.lato(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: controller.isRecording.value
                            ? Colors.white
                            : textOnOrange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Widgets (no changes from here) ---

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
      child: Text(title.toUpperCase(),
          style: GoogleFonts.lato(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: textOnBlack.withOpacity(0.6),
              letterSpacing: 0.8)),
    );
  }

  Widget _buildSensorStatusCard(MainController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
          color: sectionBackground,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: primaryOrange.withOpacity(0.2))),
      child: Obx(() {
        if (controller.isPhoneReadyForRecording.value &&
            controller.missingSensors.isEmpty) {
          return _buildStatusRow(Icons.check_circle_outline_rounded,
              Colors.green.shade500, "Device Ready: All sensors active.");
        } else if (controller.missingSensors.isNotEmpty) {
          return _buildStatusRow(Icons.warning_amber_rounded,
              Colors.orange.shade700,
              "Sensor Issue: Missing ${controller.missingSensors.join(', ')}.");
        } else {
          return _buildStatusRow(Icons.hourglass_empty_rounded,
              textOnBlack.withOpacity(0.6), "Initializing sensors...");
        }
      }),
    );
  }

  Widget _buildStatusRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
            child: Text(text,
                style: GoogleFonts.lato(
                    fontSize: 15, fontWeight: FontWeight.w600, color: color),
                overflow: TextOverflow.ellipsis,
                maxLines: 2)),
      ],
    );
  }

  Widget _buildConfigurationCard(MainController controller) {
    return Container(
      decoration: BoxDecoration(
          color: sectionBackground,
          borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => _buildStyledDropdown(
              icon: Icons.label_important_outline_rounded,
              value: controller.selectedLabel.value,
              items: ['Choose label', ...controller.labels],
              onChanged: (value) {
                if (value != null) controller.selectedLabel.value = value;
              },
            )),
            const SizedBox(height: 16),
            Obx(() => _buildStyledDropdown(
              icon: Icons.speed_rounded,
              value: controller.refreshRate.value,
              items: ['Normal', 'Fast', 'Fastest'],
              onChanged: (value) {
                if (value != null) controller.adjustRefreshRate(value);
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildRawSensorDataCard(MainController controller) {
    return Container(
      decoration: BoxDecoration(
          color: sectionBackground,
          borderRadius: BorderRadius.circular(12.0)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
        child: Column(
          children: [
            _buildSensorDataRow("Accelerometer",
                controller.accelerometerDataUI, Icons.drag_indicator_rounded, primaryOrange),
            Divider(height: 20, thickness: 1, color: primaryBlack.withOpacity(0.5)),
            _buildSensorDataRow("Gyroscope",
                controller.gyroscopeDataUI, Icons.replay_circle_filled_rounded, primaryOrange),
            Divider(height: 20, thickness: 1, color: primaryBlack.withOpacity(0.5)),
            _buildSensorDataRow("Linear Accel",
                controller.linearAccelerationDataUI, Icons.settings_ethernet_rounded, primaryOrange),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledDropdown(
      {required IconData icon,
        required String? value,
        required List<String> items,
        required ValueChanged<String?> onChanged}) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: primaryOrange, size: 24),
        filled: true,
        fillColor: primaryBlack,
        contentPadding:
        const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: textOnBlack.withOpacity(0.3))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(color: primaryOrange, width: 2)),
      ),
      value: items.contains(value) ? value : null,
      items: items.map((item) => DropdownMenuItem(
          value: item,
          child: Text(item, style: GoogleFonts.lato(fontSize: 16))))
          .toList(),
      onChanged: onChanged,
      isExpanded: true,
      icon: Icon(Icons.arrow_drop_down_rounded, color: primaryOrange, size: 30),
      dropdownColor: sectionBackground,
      style: GoogleFonts.lato(color: textOnBlack),
    );
  }

  Widget _buildSensorDataRow(
      String title, RxList<String> data, IconData icon, Color iconColor) {
    return Row(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(width: 12),
        SizedBox(
            width: 110,
            child: Text('$title:',
                style: GoogleFonts.lato(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: textOnBlack.withOpacity(0.8)))),
        const SizedBox(width: 10),
        Expanded(
            child: Obx(() => Text(data.isNotEmpty ? data.join(' | ') : "N/A",
                style: GoogleFonts.sourceCodePro(
                    fontSize: 15,
                    color: textOnBlack,
                    fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
                maxLines: 1))),
      ],
    );
  }
}