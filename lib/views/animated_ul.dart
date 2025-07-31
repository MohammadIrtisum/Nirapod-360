import 'package:flutter/material.dart';
import 'dart:ui'; // Required for BackdropFilter
import 'package:flutter_switch/flutter_switch.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:har_app2/controllers/main_controller.dart'; // NEW: Import your controller
import 'package:har_app2/views/file_location.dart';
import 'package:har_app2/views/main_activity.dart';
import 'package:har_app2/views/sensors_check.dart';
import 'package:intl/intl.dart';

class AnimatedUI extends StatefulWidget {
  @override
  State<AnimatedUI> createState() => _AnimatedUIState();
}

class _AnimatedUIState extends State<AnimatedUI> {
  // ---- Theme Colors ----
  final Color primaryOrange = Color(0xFFF57C00);
  final Color lightOrange = Color(0xFFFF9800);
  final Color darkBackground = Color(0xFF1A1A1A);
  final Color sectionBackground = Color(0xFF2C2C2C);
  final Color textOnDark = Colors.white.withOpacity(0.9);
  final Color textOnOrange = Colors.black;

  // --- State Variables ---
  // MODIFIED: These are now driven by the MainController
  // bool _connectionActive = false;
  // bool _isSafe = true;
  String todayDate = DateFormat('MMMM d, y').format(DateTime.now());

  // ---- Partner Contact State (No changes needed here) ----
  final TextEditingController _partnerWhatsAppController = TextEditingController();
  String? _savedPartnerNumber;
  final _storage = GetStorage();
  final String _partnerNumberStorageKey = 'partnerWhatsAppNumber';

  @override
  void initState() {
    super.initState();
    _loadPartnerNumber();
  }

  @override
  void dispose() {
    _partnerWhatsAppController.dispose();
    super.dispose();
  }

  // --- Methods (No changes needed here) ---
  void _loadPartnerNumber() {
    setState(() {
      _savedPartnerNumber = _storage.read(_partnerNumberStorageKey);
      _partnerWhatsAppController.text = _savedPartnerNumber ?? '';
    });
  }

  void _savePartnerNumber() {
    final String number = _partnerWhatsAppController.text.trim();
    if (number.isEmpty) { _showSnackbar(isError: true, title: 'Input Required', message: 'Please enter a WhatsApp number.'); return; }
    if (!number.startsWith('+') || number.length < 10) { _showSnackbar(isError: true, title: 'Invalid Format', message: 'Number must start with + and country code.'); return; }
    setState(() { _savedPartnerNumber = number; });
    _storage.write(_partnerNumberStorageKey, number);
    _showSnackbar(title: 'Contact Saved!', message: 'Partner number "$number" has been saved.');
    FocusScope.of(context).unfocus();
  }

  void _deletePartnerNumber() {
    setState(() { _savedPartnerNumber = null; _partnerWhatsAppController.clear(); });
    _storage.remove(_partnerNumberStorageKey);
    _showSnackbar(title: 'Contact Removed', message: 'Partner number has been removed.');
  }

  void _showSnackbar({String? title, required String message, bool isError = false}) {
    Get.snackbar(
      title ?? '', message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: isError ? Color(0xffd32f2f) : primaryOrange,
      colorText: isError ? Colors.white : textOnOrange,
      margin: EdgeInsets.all(15), borderRadius: 12,
      icon: Icon(isError ? Icons.error_outline : Icons.check_circle_outline_rounded, color: isError ? Colors.white : textOnOrange),
    );
  }

  @override
  Widget build(BuildContext context) {
    // NEW: Get an instance of the MainController. Get.put() is safe; it will create
    // an instance if it doesn't exist, or return the existing one.
    final MainController controller = Get.put(MainController());
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: darkBackground,
      body: Column(
        children: [
          _buildTopHeader(size, controller), // MODIFIED: Pass the controller down
          Expanded(
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.all(size.width * 0.04),
                child: Column(
                  children: [
                    _buildActionsSection(size),
                    SizedBox(height: size.height * 0.02),
                    _buildPartnersSection(size),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: darkBackground,
          border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1), width: 1.0)),
        ),
        child: BottomNavigationBar(
          backgroundColor: Colors.transparent,
          selectedItemColor: primaryOrange,
          unselectedItemColor: Colors.white.withOpacity(0.5),
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_filled), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart_rounded), label: 'Stats'),
            BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'Settings'),
          ],
        ),
      ),
    );
  }

  // MODIFIED: Header is now connected to the MainController
  Widget _buildTopHeader(Size size, MainController controller) {
    return Container(
      width: size.width,
      height: size.height * 0.30,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('asset/logo4.png'),
          fit: BoxFit.cover,
          opacity: 1,
        ),
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: EdgeInsets.fromLTRB(size.width * 0.05, MediaQuery.of(context).padding.top, size.width * 0.05, size.height * 0.02),
            color: sectionBackground.withOpacity(0.5),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10,),
                Text(todayDate, style: GoogleFonts.lato(fontSize: size.width * 0.04, color: textOnDark.withOpacity(0.7))),

                // MODIFIED: The whole interactive card is now wrapped in one Obx
                // to react to changes in controller.isRecording and controller.isDangerDetected.
                // The GestureDetector is removed as the state is now automatic.
                Obx(() => Container(
                  padding: EdgeInsets.all(size.width * 0.04),
                  decoration: BoxDecoration(
                    color: darkBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    // Border color reacts to danger state
                    border: Border.all(
                      color: controller.isDangerDetected.value ? Colors.red.withOpacity(0.7) : primaryOrange.withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("HAR", style: GoogleFonts.montserrat(fontSize: size.width * 0.08, fontWeight: FontWeight.bold, color: textOnDark)),
                          FlutterSwitch(
                            width: size.width * 0.22, height: size.height * 0.045, toggleSize: size.height * 0.038,
                            borderRadius: 25.0, padding: 3.0,
                            activeColor: primaryOrange, inactiveColor: darkBackground,
                            // Value is now directly from the controller's isRecording state
                            value: controller.isRecording.value,
                            // onToggle now triggers the controller's methods
                            onToggle: (val) {
                              if (val) {
                                // Turn ON -> Start Sensing/Predicting
                                controller.startRecording();
                              } else {
                                // Turn OFF -> Stop Sensing/Predicting
                                controller.stopRecording();
                              }
                            },
                          ),
                        ],
                      ),
                      Divider(color: Colors.white.withOpacity(0.2), height: size.height * 0.03),

                      // Animated status text now reacts to danger state from the controller
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                        child: !controller.isDangerDetected.value
                            ? _buildStatusText(
                            key: Key('safe_state'),
                            icon: Icons.shield_outlined,
                            text: "I am safe",
                            color: primaryOrange,
                            size: size)
                            : _buildStatusText(
                            key: Key('unsafe_state'),
                            icon: Icons.warning_amber_rounded,
                            text: "Distress Signal Active",
                            color: Colors.redAccent,
                            size: size),
                      )
                    ],
                  ),
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- No changes needed for the rest of the widgets ---

  Widget _buildStatusText({required Key key, required IconData icon, required String text, required Color color, required Size size}) {
    return Row(
      key: key,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: color, size: size.width * 0.05),
        SizedBox(width: size.width * 0.02),
        Text(text, style: GoogleFonts.lato(fontSize: size.width * 0.045, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildActionsSection(Size size) {
    return _buildSectionContainer(size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(size, title: "Quick Actions", icon: Icons.bolt_rounded),
          SizedBox(height: size.height * 0.025),
          _buildThemedButton(size, label: "Detailed View", icon: Icons.analytics_rounded, onTap: () => Get.to(() => MainActivity())),
          SizedBox(height: size.height * 0.015),
          _buildThemedButton(size, label: "Sensor Status", icon: Icons.sensors_rounded, onTap: () => Get.to(() => SensorsCheck())),
          SizedBox(height: size.height * 0.015),
          _buildThemedButton(size, label: "Storage Location", icon: Icons.folder_open_rounded, onTap: () => Get.to(() => FileLocationView())),
        ],
      ),
    );
  }

  Widget _buildPartnersSection(Size size) {
    return _buildSectionContainer(size,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(size, title: "Emergency Contact", icon: Icons.shield_outlined),
          SizedBox(height: size.height * 0.025),
          if (_savedPartnerNumber != null && _savedPartnerNumber!.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: size.height * 0.02),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.03, vertical: size.height * 0.012),
                decoration: BoxDecoration(color: darkBackground, borderRadius: BorderRadius.circular(10), border: Border.all(color: Colors.white.withOpacity(0.1))),
                child: Row(
                  children: [
                    Icon(Icons.contact_phone_rounded, color: primaryOrange, size: size.width * 0.05),
                    SizedBox(width: size.width * 0.02),
                    Expanded(child: Text("Saved: $_savedPartnerNumber", style: GoogleFonts.lato(fontSize: size.width * 0.04, color: textOnDark, fontWeight: FontWeight.w500))),
                    IconButton(icon: Icon(Icons.delete_forever_rounded, color: Colors.red.shade400), onPressed: _deletePartnerNumber, tooltip: "Remove Contact"),
                  ],
                ),
              ),
            ),
          TextField(
            controller: _partnerWhatsAppController,
            keyboardType: TextInputType.phone,
            style: GoogleFonts.lato(fontSize: size.width * 0.04, color: textOnDark),
            decoration: InputDecoration(
              hintText: "e.g., +12345678901",
              hintStyle: GoogleFonts.lato(color: Colors.white.withOpacity(0.4)),
              labelText: "Partner's WhatsApp Number",
              labelStyle: GoogleFonts.lato(color: primaryOrange.withOpacity(0.8), fontSize: size.width * 0.04),
              prefixIcon: Icon(Icons.quick_contacts_dialer_outlined, color: primaryOrange),
              filled: true,
              fillColor: darkBackground,
              contentPadding: EdgeInsets.symmetric(vertical: size.height * 0.018, horizontal: size.width * 0.04),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.white.withOpacity(0.2))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryOrange, width: 2)),
            ),
          ),
          SizedBox(height: size.height * 0.025),
          _buildThemedButton(size,
            label: _savedPartnerNumber == _partnerWhatsAppController.text.trim() && _savedPartnerNumber != null ? "Contact Saved" : "Save Contact",
            icon: _savedPartnerNumber == _partnerWhatsAppController.text.trim() && _savedPartnerNumber != null ? Icons.check_circle_rounded : Icons.save_alt_rounded,
            onTap: _savePartnerNumber,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionContainer(Size size, {required Widget child}) {
    return Container(
      padding: EdgeInsets.all(size.width * 0.05),
      decoration: BoxDecoration(color: sectionBackground, borderRadius: BorderRadius.circular(20)),
      child: child,
    );
  }

  Widget _buildSectionTitle(Size size, {required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, color: primaryOrange, size: size.width * 0.055),
        SizedBox(width: size.width * 0.025),
        Text(title, style: GoogleFonts.lato(fontSize: size.width * 0.045, fontWeight: FontWeight.bold, color: textOnDark)),
      ],
    );
  }

  Widget _buildThemedButton(Size size, {required String label, required IconData icon, required VoidCallback onTap}) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: Colors.black.withOpacity(0.4),
        highlightColor: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          width: double.infinity,
          height: size.height * 0.075,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [lightOrange, primaryOrange], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: primaryOrange.withOpacity(0.3), blurRadius: 15, offset: Offset(0, 6))],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: textOnOrange, size: size.width * 0.06),
              SizedBox(width: size.width * 0.03),
              Text(label, style: GoogleFonts.lato(color: textOnOrange, fontSize: size.width * 0.042, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}