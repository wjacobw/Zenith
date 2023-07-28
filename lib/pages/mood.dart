import 'package:flutter/material.dart';
import 'package:zenith/models/moodcard.dart';
import 'package:zenith/pages/screens/chart.dart';
import 'package:zenith/pages/screens/homepage.dart';
import 'package:zenith/pages/screens/start.dart';
import 'package:provider/provider.dart';

class MyMood extends StatelessWidget {
  const MyMood({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
        value: MoodCard(),
        child: MaterialApp(
          title: 'Flutter Demo',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            visualDensity: VisualDensity.adaptivePlatformDensity,
          ),
          home: StartPage(),
          routes: {
            '/home_screen': (ctx) => HomeScreen(),
            '/chart': (ctx) => MoodChart(),
          },
        ));
  }
}