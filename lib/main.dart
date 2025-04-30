import 'package:nurul_akbar/screens/beranda.dart';
import 'package:flutter/material.dart';
import 'package:nurul_akbar/screens/login.dart';
import 'package:get/get.dart';
import 'controllers/admin_controller.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(AdminController());  // Initialize the controller
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(  // Change MaterialApp to GetMaterialApp
      debugShowCheckedModeBanner: false,
      title: 'Nurul Akbar',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: Login(), // Set your home screen
    );
  }
}
