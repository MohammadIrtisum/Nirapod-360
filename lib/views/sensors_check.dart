import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';

class SensorsCheck extends StatelessWidget {
  const SensorsCheck({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Sensors Status Check',
        style: TextStyle(color: Colors.orange)),
        backgroundColor: Colors.transparent,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.orange),
      ),
      body: Stack(
        children: [
          // Black background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black, Color(0xFF1A1A1A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Optional: Subtle dark pattern overlay
          Opacity(
            opacity: 0.08,
            child: Image.asset(
              'assets/pattern.png',
              repeat: ImageRepeat.repeat,
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              color: Colors.black,
              colorBlendMode: BlendMode.darken,
            ),
          ),
          Center(
            child: Obx(
              () => AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: [
                    BoxShadow(
                      color: controller.isPhoneReadyForRecording.value
                          ? Colors.greenAccent.withOpacity(0.18)
                          : Colors.redAccent.withOpacity(0.12),
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                  ],
                  border: Border.all(
                    color: controller.isPhoneReadyForRecording.value
                        ? Colors.greenAccent
                        : Colors.redAccent,
                    width: 2.5,
                  ),
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 600),
                  switchInCurve: Curves.easeIn,
                  switchOutCurve: Curves.easeOut,
                  child: controller.isPhoneReadyForRecording.value
                      ? _SuccessContent()
                      : _ErrorContent(controller: controller),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('success'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: const Icon(
            Icons.verified_rounded,
            size: 110,
            color: Colors.greenAccent,
            shadows: [
              Shadow(
                color: Colors.green,
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'All Sensors Available!',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'This phone is ready for recording.',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        _RecheckButton(),
      ],
    );
  }
}

class _ErrorContent extends StatelessWidget {
  final MainController controller;
  const _ErrorContent({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('error'),
      mainAxisSize: MainAxisSize.min,
      children: [
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 800),
          builder: (context, value, child) => Transform.scale(
            scale: value,
            child: child,
          ),
          child: const Icon(
            Icons.warning_amber_rounded,
            size: 110,
            color: Colors.orangeAccent,
            shadows: [
              Shadow(
                color: Colors.redAccent,
                blurRadius: 16,
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Sensors Missing!',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            shadows: [
              Shadow(
                color: Colors.black54,
                blurRadius: 6,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'This phone is missing the following sensors:',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white70,
            fontFamily: 'Montserrat',
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...controller.missingSensors.map((sensor) => AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              margin: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[900]!.withOpacity(0.95),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(       
                    color: Colors.redAccent.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ListTile(
                leading: const Icon(
                  Icons.error_outline,
                  color: Colors.red,
                ),
                title: Text(
                  sensor,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Montserrat',
                  ),
                ),
              ),
            )),
        const SizedBox(height: 32),
        _RecheckButton(),
      ],
    );
  }
}

class _RecheckButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.find();
    return ElevatedButton.icon(
      onPressed: () => controller.checkSensors(),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
        backgroundColor: Colors.white10,
        foregroundColor: Colors.greenAccent,
        elevation: 8,
        shadowColor: Colors.greenAccent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          fontFamily: 'Montserrat',
        ),
        side: const BorderSide(color: Colors.greenAccent, width: 1.5),
      ),
      icon: const Icon(Icons.refresh),
      label: const Text('Re-check Sensors'),
    );
  }
}
