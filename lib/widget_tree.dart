import 'package:firebase_auth/firebase_auth.dart';
import 'package:zenith/pages_controller.dart';
import 'package:zenith/pages/login_register.page.dart';
import 'package:zenith/auth.dart';
import 'package:flutter/material.dart';

class WidgetTree extends StatefulWidget {
  const WidgetTree({Key? key}) : super(key: key);

  @override
  State<WidgetTree> createState() => _WidgetTreeState();
}

class _WidgetTreeState extends State<WidgetTree>  {
  @override
  Widget build(BuildContext context)  {
    return StreamBuilder(
      stream: Auth(FirebaseAuth.instance).authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.hasData)  {
          return NavigationWrapper();
        } else {
          return const LoginPage();
        }
      },
    );
  }
}