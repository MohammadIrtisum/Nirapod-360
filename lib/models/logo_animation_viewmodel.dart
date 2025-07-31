import 'dart:async';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../views/file_location.dart';
import '../views/main_activity.dart';
import '../views/sensors_check.dart';

class LogoAnimationViewModel extends GetxController {
  RxBool shouldAnimate = false.obs;
  RxBool shouldShowText = false.obs;
  RxBool circleVisible = true.obs;
  RxBool showButtonUI = false.obs;

  late Timer _timer;

  @override
  void onInit() {
    super.onInit();
    _startAnimationTimer();
  }

  void _startAnimationTimer() {
    _timer = Timer(const Duration(seconds: 1), () {
      shouldAnimate.value = true;
      shouldShowText.value = true;
    });
  }

  void hideCircleUI() {
    circleVisible.value = false; // Hide the circle
    showButtonUI.value = true; // Transition to the button UI
  }

  @override
  void onClose() {
    _timer.cancel();
    super.onClose();
  }

  // Button Actions
  void onHumanActivitiesRecorderClick() {
    Get.to(MainActivity());
    // Add navigation logic or action here
  }

  void onSensorsCheckClick() {
    Get.to(SensorsCheck());
    // Add navigation logic or action here
  }

  void onSavedActivitiesClick() {
    Get.snackbar('Sorry!!!', 'This feature will be add soon...');
    // Add navigation logic or action here
  }

  void onFileLocationClick() {
    Get.to(FileLocationView());
    // Add navigation logic or action here
  }
}
