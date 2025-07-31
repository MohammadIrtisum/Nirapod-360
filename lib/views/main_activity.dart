// lib/views/main_tab_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/main_controller.dart';
import 'data_recorder_view.dart';
import 'prediction_view.dart';
import 'package:har_app2/views/add_label_dialog.dart';
import '../views/map.dart';

class MainActivity extends StatefulWidget {
  const MainActivity({super.key});

  @override
  State<MainActivity> createState() => _MainTabViewState();
}

class _MainTabViewState extends State<MainActivity> {
  final MainController controller = Get.put(MainController());
  int _selectedIndex = 0;

  static const Color primaryColor = Colors.orange;
  static const Color backgroundColor = Colors.black;

  late final List<Widget> _widgetOptions;

  @override
  void initState() {
    super.initState();
    _widgetOptions = <Widget>[
      DataRecorderView(controller: controller),
      PredictionView(controller: controller),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _buildAppBarActions() {
    if (_selectedIndex == 0) {
      return [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, color: Colors.orange, size: 28),
          tooltip: 'Add New Activity Label (for CSV)',
          onPressed: () => Get.dialog(AddLabelDialog()),
        ),
      ];
    } else if (_selectedIndex == 1) {
      return [
        IconButton(
          icon: const Icon(Icons.science_outlined, color: Colors.orange, size: 28),
          tooltip: 'Add Mock Data (for TFLite)',
          onPressed: controller.addMockTFLiteSensorData,
        ),
        IconButton(
          icon: const Icon(Icons.person_pin_circle_outlined, color: Colors.orange, size: 28),
          tooltip: 'Simulate Danger & Open Map',
          onPressed: () {
            controller.simulateDangerAndSendAlert();
          },
        ),
      ];
    }
    return [];
  }

  String _getAppBarTitle() {
    switch (_selectedIndex) {
      case 0:
        return 'HAR CSV Recorder';
      case 1:
        return 'HAR Real-time Prediction';
      default:
        return 'HAR Monitor';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          _getAppBarTitle(),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange),
        ),
        backgroundColor: backgroundColor,
        elevation: 2.0,
        centerTitle: true,
        actions: _buildAppBarActions(),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _widgetOptions,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.save_alt_rounded),
            label: 'CSV Recorder',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.online_prediction_rounded),
            label: 'Prediction',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.white,
        backgroundColor: backgroundColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        elevation: 8.0,
      ),
    );
  }
}
