import 'dart:async';

import 'package:get/get.dart';

// class LogoAnimationController extends GetxController {
//   // Observable variables
//   var shouldAnimate = false.obs;
//   var shouldShowText = false.obs;
//
//   // Method to initialize animation
//   Future<void> initAnimate() async {
//     await Future.delayed(const Duration(seconds: 1), () {
//       shouldAnimate.value = true;
//       shouldShowText.value = true;
//     });
//   }
//
//   @override
//   void onInit() {
//     super.onInit();
//     initAnimate();
//   }
// }

class LogoAnimationController extends GetxController {
  RxBool shouldAnimate = false.obs;
  RxBool shouldShowText = false.obs;
  late Timer timer;

  @override
  void onInit() {
    super.onInit();
    _startAnimationTimer();
  }

  void _startAnimationTimer() {
    timer = Timer(const Duration(seconds: 1), () {
      shouldAnimate.value = true;
      shouldShowText.value = true;
    });
  }

  @override
  void onClose() {
    timer.cancel();
    super.onClose();
  }
}