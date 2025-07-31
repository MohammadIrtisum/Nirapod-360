import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:har_app2/views/logo_animation.dart';
import 'package:har_app2/views/logo_animation_view.dart';
import 'package:har_app2/views/recording_view.dart';
import 'firebase/firebase_options.dart';
import 'views/main_activity.dart';


// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );


  // Enable offline persistence for Firebase Realtime Database
  // FirebaseDatabase.instance.setPersistenceEnabled(true);

//   runApp(const HARRecorderApp());
// }
void main() {
  runApp(HARRecorderApp());
}



class HARRecorderApp extends StatelessWidget {
  const HARRecorderApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: LogoAnimation(),
    );
  }
}
