// ../controllers/main_controller.dart

import 'dart:async';
import 'dart:convert'; // For jsonEncode and jsonDecode
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:csv/csv.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:math';

import 'package:get_storage/get_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

import '../views/map.dart';

const int NUM_FEATURES = 9;

final List<double> featureMeans = const [
  0.1, 0.2, 9.8, 0.01, 0.02, 0.03, 0.05, 0.06, 0.07
];
final List<double> featureStdDevs = const [
  1.5, 1.6, 1.2, 0.5, 0.6, 0.7, 0.8, 0.9, 1.0
];

// Ensure this is correct, including the port!
final String _apiPredictionUrl = 'http://192.168.0.109:5000/predict';

// Define which activity strings are considered "Abnormal"
const List<String> _abnormalActivityStrings = [
  "Jumping", "Running", "Stambling", "Falling_down", "Kicking", "Punching", "Pushing",
  // Add any other activity names from your model that should be considered abnormal
];

class MainController extends GetxController {
  final _storage = GetStorage();
  final String _partnerNumberStorageKey = 'partnerWhatsAppNumber';
  var isRecording = false.obs;
  var selectedLabel = 'Choose label'.obs;
  var refreshRate = 'Normal'.obs;
  var status = 'Idle'.obs;
  var isPhoneReadyForRecording = false.obs;
  var missingSensors = <String>[].obs;

  var labels = ['Running', 'Standing', 'Sitting', 'Walking', 'Falling_down', 'Jumping', 'Kicking', 'Punching', 'Pushing', 'Stambling', 'Climbing_Up', 'Climbing_Down', 'Inactive'].obs;

  var accelerometerDataUI = <String>['0.00', '0.00', '0.00'].obs;
  var gyroscopeDataUI = <String>['0.00', '0.00', '0.00'].obs;
  var linearAccelerationDataUI = <String>['0.00', '0.00', '0.00'].obs;

  StreamSubscription? accelerometerStreamSub;
  StreamSubscription? gyroscopeStreamSub;
  StreamSubscription? userAccelerationStreamSub;

  List<List<dynamic>> recordedDataForCSV = [];

  RxString currentPrediction = "Prediction Service Idle".obs;
  RxBool isAbnormal = false.obs; // True if current activity string is in _abnormalActivityStrings

  List<double> _latestAccelRaw = [0.0, 0.0, 0.0];
  List<double> _latestGyroRaw = [0.0, 0.0, 0.0];
  List<double> _latestLinearAccelRaw = [0.0, 0.0, 0.0];

  bool _hasNewAccelForModel = false;
  bool _hasNewGyroForModel = false;
  bool _hasNewLinearAccelForModel = false;

  Timer? _csvDataCollectorTimer;

  var isDangerDetected = false.obs;
  int _abnormalActivityCount = 0;
  DateTime? _dangerCountWindowStartTime;
  static const int _dangerCountThreshold = 300; // Reduced for easier testing; adjust back later
  static const Duration _dangerCountWindowDuration = Duration(minutes: 3); // Reduced for easier testing; adjust back

  var isSendingEmergencyMessage = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkPermissions();
    checkSensors();
    _checkScalerConfig();
    if (currentPrediction.value != "Scaler Config Error!") {
      currentPrediction.value = "Prediction API Ready. Waiting for data...";
    }
    print("MainController initialized for API prediction");
  }

  void _checkScalerConfig() {
    if (featureMeans.length != NUM_FEATURES || featureStdDevs.length != NUM_FEATURES) {
      String errorMsg = "CRITICAL: Scaler arrays (means/stdDevs) length mismatch. Check constants.";
      print(errorMsg);
      currentPrediction.value = "Scaler Config Error!";
      Get.snackbar("Config Error", errorMsg, backgroundColor: Colors.red, colorText: Colors.white, duration: Duration(seconds: 10));
    }
  }

  void _onNewSensorDataForModel(String sensorType, List<double> rawData) {
    if (!isRecording.value) return;

    switch (sensorType) {
      case "Accelerometer": _latestAccelRaw = List.from(rawData); _hasNewAccelForModel = true; break;
      case "Gyroscope": _latestGyroRaw = List.from(rawData); _hasNewGyroForModel = true; break;
      case "LinearAcceleration": _latestLinearAccelRaw = List.from(rawData); _hasNewLinearAccelForModel = true; break;
    }

    if (_hasNewAccelForModel && _hasNewGyroForModel && _hasNewLinearAccelForModel) {
      _prepareAndRunPrediction();
      _hasNewAccelForModel = false; _hasNewGyroForModel = false; _hasNewLinearAccelForModel = false;
    }
  }

  Future<void> _prepareAndRunPrediction() async {
    if (currentPrediction.value == "Scaler Config Error!") return;

    List<double> currentFeatures = [..._latestAccelRaw, ..._latestGyroRaw, ..._latestLinearAccelRaw];

    if (currentFeatures.length != NUM_FEATURES) {
      print("Error: Combined feature length (${currentFeatures.length}) != NUM_FEATURES ($NUM_FEATURES)");
      currentPrediction.value = "Feature Count Error!"; return;
    }

    List<double> normalizedFeatures = List.generate(NUM_FEATURES, (i) =>
    (featureStdDevs[i] == 0) ? (currentFeatures[i] - featureMeans[i]) : (currentFeatures[i] - featureMeans[i]) / featureStdDevs[i]
    );

    final url = Uri.parse(_apiPredictionUrl);
    try {
      final payload = jsonEncode({'features': [normalizedFeatures]});
      // print("Sending to API: $payload"); // Optional: log what you're sending

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: payload,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);
        // print("API Response: $responseBody"); // Optional: log what you received

        if (responseBody.containsKey('prediction') && responseBody['prediction'] is String) {
          String activityString = responseBody['prediction'];
          currentPrediction.value = "Activity: $activityString"; // Update UI state directly

          // Determine if this activity is abnormal
          isAbnormal.value = _abnormalActivityStrings.contains(activityString);

        } else if (responseBody.containsKey('error')) {
          print("API returned an error: ${responseBody['error']}");
          currentPrediction.value = "API Error: Server Issue";
          isAbnormal.value = false;
        }
        else {
          print("Unexpected prediction format from API: $responseBody. Expected String in 'prediction'.");
          currentPrediction.value = "API Resp Fmt Err";
          isAbnormal.value = false;
        }
      } else {
        print('API request failed with status: ${response.statusCode}. Body: ${response.body}');
        currentPrediction.value = "API Error: ${response.statusCode}";
        isAbnormal.value = false;
      }
    } on TimeoutException catch (_) {
      print("API call timed out.");
      currentPrediction.value = "API Call Timeout"; // More specific for UI
      isAbnormal.value = false;
    } catch (e) {
      print("Error during API call: $e");
      currentPrediction.value = "Network/API Error"; // More specific for UI
      isAbnormal.value = false;
    }

    _handleDangerDetectionLogic();
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Location Disabled', 'Location services are disabled. Please enable them.',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Location Denied', 'Location permissions are denied.',
            snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Location Denied Forever', 'Location permissions are permanently denied, we cannot request permissions.',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 15)
      );
    } on TimeoutException catch (_) {
      Get.snackbar('Location Timeout', 'Could not get location in time. Try moving to an open area.',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.orange, colorText: Colors.white);
      return null;
    } catch (e) {
      print("Error getting location: $e");
      Get.snackbar('Location Error', 'Failed to get current location: ${e.toString()}',
          snackPosition: SnackPosition.TOP, backgroundColor: Colors.red, colorText: Colors.white);
      return null;
    }
  }


  void _handleDangerDetectionLogic() {
    if (!isRecording.value) {
      _resetDangerDetectionState();
      return;
    }

    if (_dangerCountWindowStartTime == null ||
        DateTime.now().difference(_dangerCountWindowStartTime!) > _dangerCountWindowDuration) {
      _dangerCountWindowStartTime = DateTime.now();
      _abnormalActivityCount = 0;
      if (isDangerDetected.value && !isSendingEmergencyMessage.value) {
        isDangerDetected.value = false;
      }
      print("DangerLogic: New ${(_dangerCountWindowDuration.inSeconds/60).toStringAsFixed(0)}-minute window started at $_dangerCountWindowStartTime. Count reset.");
    }

    if (isAbnormal.value) {
      _abnormalActivityCount++;
      print("DangerLogic: Abnormal activity detected. Count: $_abnormalActivityCount / $_dangerCountThreshold in current window.");

      if (_abnormalActivityCount >= _dangerCountThreshold && !isDangerDetected.value && !isSendingEmergencyMessage.value) {
        isSendingEmergencyMessage.value = true;
        isDangerDetected.value = true;
        _showDangerSnackbar();
        print("DANGER DETECTED! Threshold of $_dangerCountThreshold abnormal activities reached. Attempting to send message and show map.");

        _getCurrentLocation().then((Position? position) {
          if (position != null) {
            sendEmergencyMessageWithLocation(position.latitude.toString(), position.longitude.toString()).then((_) {
              Get.to(() => CurrentLocationMap());
            }).whenComplete(() {
              isSendingEmergencyMessage.value = false;
            });
          } else {
            print("Failed to get location for emergency message.");
            Get.to(() => const CurrentLocationMap());
            isSendingEmergencyMessage.value = false;
          }
        }).catchError((e) {
          print("Error in _getCurrentLocation chain: $e");
          Get.to(() => const CurrentLocationMap());
          isSendingEmergencyMessage.value = false;
        });
      }
    }
  }

  void _resetDangerDetectionState() {
    _abnormalActivityCount = 0;
    _dangerCountWindowStartTime = null;
    if (isDangerDetected.value && !isSendingEmergencyMessage.value) {
      isDangerDetected.value = false;
    }
    print("DangerLogic: Danger detection count and window potentially reset.");
  }

  void _showDangerSnackbar() {
    Get.snackbar(
      "DANGER DETECTED!",
      "High frequency of abnormal activity! ($_dangerCountThreshold+ times in ${_dangerCountWindowDuration.inMinutes} min). Taking action.",
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.red.shade700,
      colorText: Colors.white,
      duration: const Duration(seconds: 10),
      isDismissible: true,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 30),
      margin: const EdgeInsets.all(15),
      borderRadius: 10,
      barBlur: 10,
      overlayBlur: 5,
    );
  }

  Future<void> checkSensors() async {
    missingSensors.clear();
    isPhoneReadyForRecording.value = true;

    const sensorCheckTimeout = Duration(milliseconds: 500);

    var accAvailable = await _isSensorAvailable(accelerometerEventStream()).timeout(sensorCheckTimeout, onTimeout: () => false);
    if (!accAvailable) {
      missingSensors.add('Accelerometer');
      isPhoneReadyForRecording.value = false;
    }
    var gyroAvailable = await _isSensorAvailable(gyroscopeEventStream()).timeout(sensorCheckTimeout, onTimeout: () => false);
    if (!gyroAvailable) {
      missingSensors.add('Gyroscope');
      isPhoneReadyForRecording.value = false;
    }
    var userAccAvailable = await _isSensorAvailable(userAccelerometerEventStream()).timeout(sensorCheckTimeout, onTimeout: () => false);
    if (!userAccAvailable) {
      missingSensors.add('Linear Acceleration (User)');
      isPhoneReadyForRecording.value = false;
    }

    if (isPhoneReadyForRecording.value) {
      status.value = "Ready to Record";
      Get.snackbar('Success', 'Device ready for recording and prediction!');
    } else {
      status.value = "Sensors Missing!";
      Get.snackbar('Warning', 'Missing sensors for full functionality: ${missingSensors.join(', ')}');
    }
  }

  Future<bool> _isSensorAvailable(Stream<dynamic> sensorStream) async {
    Completer<bool> completer = Completer();
    StreamSubscription? subscription;
    Timer timeoutTimer = Timer(const Duration(milliseconds: 400), () {
      if (!completer.isCompleted) {
        print("Sensor availability check timed out for a stream.");
        subscription?.cancel();
        completer.complete(false);
      }
    });
    try {
      subscription = sensorStream.listen(
              (event) {
            if (!completer.isCompleted) {
              subscription?.cancel();
              timeoutTimer.cancel();
              completer.complete(true);
            }
          },
          onError: (e) {
            if (!completer.isCompleted) {
              print("Error listening to sensor stream: $e");
              subscription?.cancel();
              timeoutTimer.cancel();
              completer.complete(false);
            }
          },
          onDone: () {
            if (!completer.isCompleted) {
              timeoutTimer.cancel();
              completer.complete(false);
            }
          }
      );
    } catch (e) {
      if (!completer.isCompleted) {
        print("Exception setting up sensor listener: $e");
        timeoutTimer.cancel();
        await subscription?.cancel();
        completer.complete(false);
      }
    }
    return completer.future;
  }

  Future<void> checkPermissions() async {
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      storageStatus = await Permission.storage.request();
    }
    var locationStatus = await Permission.location.status;
    if (!locationStatus.isGranted) {
      locationStatus = await Permission.location.request();
    }

    if(!storageStatus.isGranted) {
      Get.snackbar("Permission Error", "Storage permission is required to save data.", backgroundColor: Colors.red, colorText: Colors.white);
    }
    if(!locationStatus.isGranted) {
      Get.snackbar("Permission Error", "Location permission is required for emergency alerts.", backgroundColor: Colors.orange, colorText: Colors.white);
    }
  }

  /// **MODIFIED: This method now starts prediction immediately.**
  /// Selecting a label is optional and only enables background CSV data collection.
  void startRecording() {
    if (!isPhoneReadyForRecording.value) {
      Get.snackbar('Error', 'Cannot start. Missing sensors: ${missingSensors.join(', ')}');
      return;
    }

    isRecording.value = true;
    currentPrediction.value = "Awaiting sensor data...";
    isAbnormal.value = false;
    isSendingEmergencyMessage.value = false;
    _resetDangerDetectionState();

    _hasNewAccelForModel = false;
    _hasNewGyroForModel = false;
    _hasNewLinearAccelForModel = false;

    // Clear any previous CSV data.
    recordedDataForCSV.clear();

    // Start all sensor streams for prediction. This is now the primary action.
    accelerometerStreamSub = accelerometerEventStream(samplingPeriod: _getSensorSamplingPeriod())
        .listen((AccelerometerEvent event) {
      if (!isRecording.value) return;
      accelerometerDataUI.value = [event.x.toStringAsFixed(3), event.y.toStringAsFixed(3), event.z.toStringAsFixed(3)];
      _onNewSensorDataForModel("Accelerometer", [event.x, event.y, event.z]);
    });

    gyroscopeStreamSub = gyroscopeEventStream(samplingPeriod: _getSensorSamplingPeriod())
        .listen((GyroscopeEvent event) {
      if (!isRecording.value) return;
      gyroscopeDataUI.value = [event.x.toStringAsFixed(3), event.y.toStringAsFixed(3), event.z.toStringAsFixed(3)];
      _onNewSensorDataForModel("Gyroscope", [event.x, event.y, event.z]);
    });

    userAccelerationStreamSub = userAccelerometerEventStream(samplingPeriod: _getSensorSamplingPeriod())
        .listen((UserAccelerometerEvent event) {
      if (!isRecording.value) return;
      linearAccelerationDataUI.value = [event.x.toStringAsFixed(3), event.y.toStringAsFixed(3), event.z.toStringAsFixed(3)];
      _onNewSensorDataForModel("LinearAcceleration", [event.x, event.y, event.z]);
    });


    // Conditionally start CSV data collection if a label has been selected.
    if (selectedLabel.value != 'Choose label') {
      // Data collection mode is active alongside prediction.
      status.value = "Recording: ${selectedLabel.value} & Predicting";
      recordedDataForCSV.add([
        'acc_x', 'acc_y', 'acc_z',
        'gyro_x', 'gyro_y', 'gyro_z',
        'la_x', 'la_y', 'la_z',
        'ActivityLabel'
      ]);

      _csvDataCollectorTimer?.cancel();
      _csvDataCollectorTimer = Timer.periodic(_getSamplingDurationForCSV(), (timer) {
        if (!isRecording.value) {
          timer.cancel();
          return;
        }
        recordedDataForCSV.add([
          accelerometerDataUI.value.isNotEmpty ? accelerometerDataUI.value[0] : '0.0',
          accelerometerDataUI.value.length > 1 ? accelerometerDataUI.value[1] : '0.0',
          accelerometerDataUI.value.length > 2 ? accelerometerDataUI.value[2] : '0.0',
          gyroscopeDataUI.value.isNotEmpty ? gyroscopeDataUI.value[0] : '0.0',
          gyroscopeDataUI.value.length > 1 ? gyroscopeDataUI.value[1] : '0.0',
          gyroscopeDataUI.value.length > 2 ? gyroscopeDataUI.value[2] : '0.0',
          linearAccelerationDataUI.value.isNotEmpty ? linearAccelerationDataUI.value[0] : '0.0',
          linearAccelerationDataUI.value.length > 1 ? linearAccelerationDataUI.value[1] : '0.0',
          linearAccelerationDataUI.value.length > 2 ? linearAccelerationDataUI.value[2] : '0.0',
          selectedLabel.value,
        ]);
      });
      print("Started: Prediction AND Data Collection for CSV are active.");
    } else {
      // Prediction-only mode.
      status.value = "Sensing & Predicting";
      _csvDataCollectorTimer?.cancel(); // Ensure timer is stopped if it was running before.
      print("Started: Prediction-ONLY mode is active.");
    }
  }

  Duration _getSamplingDurationForCSV() {
    switch (refreshRate.value) {
      case 'Fastest': return const Duration(milliseconds: 20);
      case 'Fast': return const Duration(milliseconds: 50);
      case 'Normal':
      default:
        return const Duration(milliseconds: 100);
    }
  }

  Duration _getSensorSamplingPeriod() {
    switch (refreshRate.value) {
      case 'Fastest': return SensorInterval.gameInterval;
      case 'Fast': return SensorInterval.uiInterval;
      case 'Normal':
      default:
        return SensorInterval.normalInterval;
    }
  }

  void stopRecording() {
    if (!isRecording.value) return;

    isRecording.value = false;
    status.value = "Processing & Saving...";

    _csvDataCollectorTimer?.cancel();
    accelerometerStreamSub?.cancel();
    gyroscopeStreamSub?.cancel();
    userAccelerationStreamSub?.cancel();

    isSendingEmergencyMessage.value = false;
    _resetDangerDetectionState();

    saveDataToCSV().then((_) {
      // The status will show data saved even if no data was logged, which is fine.
      status.value = "Stopped. Data Saved.";
    }).catchError((e) {
      status.value = "Error saving data.";
      Get.snackbar('Error', 'Failed during CSV save: $e');
    });
    currentPrediction.value = "Recording Paused. API Ready."; // Or a similar appropriate message
    print("Recording Stopped, streams canceled, CSV timer stopped.");
  }

  Future<void> saveDataToCSV() async {
    // This check correctly handles the case where we were in prediction-only mode.
    if (recordedDataForCSV.length <= 1) {
      Get.snackbar('Info', 'No data logged to save.');
      recordedDataForCSV.clear();
      return;
    }
    try {
      var storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted && !(await Permission.manageExternalStorage.isGranted)) {
        Get.snackbar('Error', 'Storage permission denied. Cannot save file.');
        return;
      }
      final Directory? downloadsDir = await getExternalStoragePublicDirectory(DirType.downloadDirectory);
      Directory appSpecificDir;
      if (downloadsDir != null) {
        appSpecificDir = Directory('${downloadsDir.path}/HAR_Recorder_CSVs');
        print("Attempting to save in: ${appSpecificDir.path}");
      } else {
        final appDocDir = await getApplicationDocumentsDirectory();
        appSpecificDir = Directory('${appDocDir.path}/HAR_Recorder_CSVs');
        Get.snackbar('Info', 'Saving to app-specific documents folder as Downloads folder was not accessible.');
        print("Saving to app-specific documents: ${appSpecificDir.path}");
      }
      if (!await appSpecificDir.exists()) {
        await appSpecificDir.create(recursive: true);
      }
      final timestamp = DateTime.now().toIso8601String().replaceAll(':', '-').replaceAll('.', '-');
      final filePath = "${appSpecificDir.path}/sensor_data_$timestamp.csv";
      String csvData = const ListToCsvConverter().convert(recordedDataForCSV);
      final file = File(filePath);
      await file.writeAsString(csvData);
      Get.snackbar('Success', 'File saved to: $filePath', duration: Duration(seconds: 5));
      print("CSV Saved: $filePath");
    } catch (e) {
      Get.snackbar('Error', 'Failed to save CSV file: $e');
      print("Error Saving CSV: $e");
    } finally {
      recordedDataForCSV.clear();
    }
  }

  StorageDirectory _getPublicDirType(DirType type) {
    switch (type) {
      case DirType.downloadDirectory:
        return StorageDirectory.downloads;
      case DirType.documentsDirectory:
        return StorageDirectory.documents;
      default:
        return StorageDirectory.downloads;
    }
  }

  Future<Directory?> getExternalStoragePublicDirectory(DirType type) async {
    if (Platform.isAndroid) {
      try {
        final List<Directory>? dirs = await getExternalStorageDirectories(type: _getPublicDirType(type));
        if (dirs != null && dirs.isNotEmpty) {
          return dirs[0];
        }
      } catch (e) {
        print("Error accessing external storage directories: $e");
      }
      if (type == DirType.downloadDirectory) {
        Directory traditionalDownloads = Directory('/storage/emulated/0/Download');
        try {
          if (await traditionalDownloads.exists()) {
            var status = await Permission.manageExternalStorage.status;
            if(status.isGranted) return traditionalDownloads;
            var regularStorageStatus = await Permission.storage.status;
            if(regularStorageStatus.isGranted) return traditionalDownloads;
          }
        } catch (e) {
          print("Could not access /storage/emulated/0/Download: $e");
        }
      }
    }
    return null;
  }

  /// **MODIFIED: Now correctly restarts the session without requiring a label.**
  void adjustRefreshRate(String rate) {
    refreshRate.value = rate;
    if (isRecording.value) {
      print("Adjusting refresh rate: Stopping and restarting recording...");
      stopRecording();
      // Use a short delay to allow `stopRecording`'s async parts to fire off
      // before restarting. The new `startRecording` handles both prediction-only
      // and data collection modes automatically.
      Future.delayed(const Duration(milliseconds: 500), () {
        startRecording();
      });
    }
    print("Refresh rate set to '$rate'. Will apply on next start, or is now active if it was already running.");
  }


  @override
  void onClose() {
    accelerometerStreamSub?.cancel();
    gyroscopeStreamSub?.cancel();
    userAccelerationStreamSub?.cancel();
    _csvDataCollectorTimer?.cancel();
    print("MainController closed and resources released.");
    super.onClose();
  }

  void addMockTFLiteSensorData() {
    if (!isRecording.value) {
      Get.snackbar("Info", "Please start sensing/recording to add mock data for prediction.", snackPosition: SnackPosition.BOTTOM);
      return;
    }
    var r = Random();
    if (NUM_FEATURES >= 9 && featureMeans.length >= 9 && featureStdDevs.length >=9 ) {
      _onNewSensorDataForModel("Accelerometer", [ featureMeans[0] + 5 * featureStdDevs[0], featureMeans[1] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[1], featureMeans[2] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[2] ]);
      _onNewSensorDataForModel("Gyroscope", [ featureMeans[3] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[3], featureMeans[4] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[4], featureMeans[5] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[5] ]);
      _onNewSensorDataForModel("LinearAcceleration", [ featureMeans[6] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[6], featureMeans[7] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[7], featureMeans[8] + (r.nextDouble() - 0.5) * 2 * featureStdDevs[8] ]);
      Get.snackbar("Mock Data", "Mock sensor data sent for API prediction.", snackPosition: SnackPosition.BOTTOM, duration: Duration(seconds: 1));
    } else {
      Get.snackbar("Config Error", "NUM_FEATURES or scaler constants not set correctly for mock data.", snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> sendEmergencyMessageWithLocation(String latitude, String longitude) async {
    String? partnerNumber = _storage.read(_partnerNumberStorageKey);

    if (partnerNumber == null || partnerNumber.isEmpty) {
      print("MainController: No emergency contact number found in storage.");
      Get.snackbar(
        "No Contact",
        "Emergency contact number not set. Please set it in the app.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.orange.shade700,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      );
      return;
    }

    String dangerMessage = "🚨 EMERGENCY! I need help!";
    String locationLink = "https://www.google.com/maps?q=$latitude,$longitude";
    String fullMessage = "$dangerMessage\nMy current location is: $locationLink";

    String whatsappUriNumber = partnerNumber;
    if (whatsappUriNumber.startsWith('+')) {
      whatsappUriNumber = whatsappUriNumber.substring(1);
    }
    whatsappUriNumber = whatsappUriNumber.replaceAll(RegExp(r'[^\d]'), '');

    final Uri whatsappUri = Uri.parse(
        "https://wa.me/$whatsappUriNumber?text=${Uri.encodeComponent(fullMessage)}");

    try {
      if (await canLaunchUrl(whatsappUri)) {
        await launchUrl(
          whatsappUri,
          mode: LaunchMode.externalApplication,
        );
        print("MainController: Emergency message intent sent to WhatsApp.");
        Get.snackbar("Alert Sent", "Emergency message sent via WhatsApp.", snackPosition: SnackPosition.TOP, backgroundColor: Colors.green, colorText: Colors.white);

      } else {
        print("MainController: Could not launch WhatsApp. Is it installed?");
        Get.snackbar(
          "WhatsApp Error",
          "Could not open WhatsApp. Please ensure it is installed.",
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red.shade600,
          colorText: Colors.white,
          margin: const EdgeInsets.all(15),
          icon: const Icon(Icons.error_outline, color: Colors.white),
        );
      }
    } catch (e) {
      print("MainController: Error launching WhatsApp - $e");
      Get.snackbar(
        "Error",
        "An unexpected error occurred while trying to send the message.",
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(15),
        icon: const Icon(Icons.error_outline, color: Colors.white),
      );
    }
  }

  void simulateDangerAndSendAlert() async {
    print("Simulating danger detection...");
    if (!isRecording.value) {
      // Start recording if not already started to simulate a real scenario
      startRecording();
    }

    // To simulate, let's force an "abnormal" string prediction
    currentPrediction.value = "Activity: Falling_down"; // Example abnormal activity
    isAbnormal.value = _abnormalActivityStrings.contains("Falling_down");

    _dangerCountWindowStartTime = DateTime.now().subtract(const Duration(seconds: 10));
    _abnormalActivityCount = _dangerCountThreshold - 1; // one short of threshold

    // We've manually set isAbnormal, so directly call the logic multiple times to trigger the alarm.
    for (int i=0; i < 2; i++) {
      _handleDangerDetectionLogic();
    }
  }
}

enum DirType {
  downloadDirectory,
  documentsDirectory,
}