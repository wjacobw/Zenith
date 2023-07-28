import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:zenith/widget_tree.dart';
import 'package:get/get.dart';
import 'package:zenith/pages/home_page.dart';

void main() async {
  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  Get.put(TimerController());
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ).copyWith(
        useMaterial3: false,
        appBarTheme: const AppBarTheme().copyWith(
          backgroundColor: const Color.fromARGB(145, 255, 255, 255),
          foregroundColor: Colors.black,
          titleSpacing: 10,
        ),
      ),
      home: const WidgetTree(),
    );
  }
}
