import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// IMPORTANT: These paths must be correct for your project structure
import 'package:har_app2/views/animated_ul.dart';
import '../controllers/animationL_controller.dart';

class LogoAnimation extends StatelessWidget {
  const LogoAnimation({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // This line correctly finds the controller you already defined in its own file.
    final LogoAnimationController controller =
    Get.put(LogoAnimationController());

    return Scaffold(
      body: Container(
        width: size.width,
        height: size.height,
        // Themed Background Gradient
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF2c2c2c), Colors.black],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Obx(
                () => GestureDetector(
              onTap: () {
                // Trigger animation and navigate after a delay
                controller.shouldAnimate.value = true;
                Timer(const Duration(milliseconds: 1500), () {
                  // Using a lambda function `() =>` is the recommended way for Get.to
                  Get.to(() =>  AnimatedUI());
                });
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outermost Ring: Vibrant orange with an orange glow
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutBack,
                    width: controller.shouldAnimate.value
                        ? size.width * .60
                        : size.width * .42,
                    height: controller.shouldAnimate.value
                        ? size.width * .60
                        : size.width * .42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF57C00), // Strong orange
                      borderRadius: BorderRadius.circular(1000),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orangeAccent.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                  ),
                  // Middle Ring: Dark charcoal for contrast
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutBack,
                    width: controller.shouldAnimate.value
                        ? size.width * .52
                        : size.width * .42,
                    height: controller.shouldAnimate.value
                        ? size.width * .52
                        : size.width * .42,
                    decoration: BoxDecoration(
                      color: const Color(0xFF333333), // Dark charcoal grey
                      borderRadius: BorderRadius.circular(1000),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.4),
                          blurRadius: 25,
                          offset: const Offset(5, 10),
                        ),
                      ],
                    ),
                  ),
                  // Innermost (static) Ring: Black, with an orange shadow
                  Container(
                    width: size.width * .42,
                    height: size.width * .42,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(1000),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.orange.withOpacity(0.15),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  // Themed Image Glow: Fiery orange
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 1500),
                    curve: Curves.easeIn,
                    opacity: controller.shouldAnimate.value ? 1 : 0,
                    child: Container(
                      width: size.width * 0.35,
                      height: size.width * 0.35,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.deepOrange.withOpacity(0.7),
                            blurRadius: 15,
                            spreadRadius: 3,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'asset/logo4.png', // Your image path
                          fit: BoxFit.cover,
                        ),
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
}

// ** THE DUPLICATE CONTROLLER CLASS HAS BEEN REMOVED FROM THIS FILE. **
// This file now correctly uses the controller imported from '../controllers/animationL_controller.dart'