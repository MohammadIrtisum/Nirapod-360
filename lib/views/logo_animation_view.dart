import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/logo_animation_viewmodel.dart';


class LogoAnimationView extends StatelessWidget {
  const LogoAnimationView({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final LogoAnimationViewModel controller = Get.put(LogoAnimationViewModel());

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Obx(
                () => Column(
              children: [
                // Menu Button
                Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: controller.hideCircleUI,
                    child: const Icon(Icons.menu, size: 30),
                  ),
                ),

                const SizedBox(height: 50),

                // Animated Circle or Buttons
                if (!controller.showButtonUI.value)
                  _buildAnimatedCircle(size, controller)
                else
                  _buildButtonUI(size, controller),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedCircle(Size size, LogoAnimationViewModel controller) {
    return Center(
      child: GestureDetector(
        onTap: controller.hideCircleUI,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOut,
              width: controller.shouldAnimate.value ? size.width * 0.55 : size.width * 0.41,
              height: controller.shouldAnimate.value ? size.width * 0.55 : size.width * 0.41,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeOut,
              width: controller.shouldAnimate.value ? size.width * 0.48 : size.width * 0.41,
              height: controller.shouldAnimate.value ? size.width * 0.48 : size.width * 0.41,
              decoration: BoxDecoration(
                color: Colors.black38,
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            Container(
              width: size.width * 0.41,
              height: size.width * 0.41,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(1000),
              ),
            ),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 2000),
              opacity: controller.shouldAnimate.value ? 1 : 0,
              child: const Text(
                "GO",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButtonUI(Size size, LogoAnimationViewModel controller) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _animatedButton(size, "Human Activities Recorder", controller.onHumanActivitiesRecorderClick),
          const SizedBox(height: 20),
          _animatedButton(size, "Sensors Check", controller.onSensorsCheckClick),
          const SizedBox(height: 20),
          _animatedButton(size, "Saved Activities", controller.onSavedActivitiesClick),
          const SizedBox(height: 20),
          _animatedButton(size, "File Location", controller.onFileLocationClick),
        ],
      ),
    );
  }

  Widget _animatedButton(Size size, String title, VoidCallback onPressed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: Size(size.width * 0.8, 60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }
}
