import 'package:flutter/material.dart';
import 'package:zenith/pages/home_page.dart';
import 'package:zenith/pages/schedule_page.dart'; 
import 'package:zenith/pages/mood.dart';
import 'package:zenith/pages/statistics.dart';
import 'package:zenith/pages/setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class NavigationWrapper extends StatefulWidget {
  @override
  _NavigationWrapperState createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    HomePage(FirebaseAuth.instance, FirebaseFirestore.instance),
    const SchedulePage(),
    MyMood(),
    Statistics(),
    SettingPage(),
    // Webview(animation: 'Base', room: 'blue'),

  ];

  void _showPopup(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home'),
                onTap: () {
                  _navigateTo(0);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text('Search'),
                onTap: () {
                  _navigateTo(1);
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  _navigateTo(2);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _navigateTo(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Widget _navigationBar(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
            color: Colors.black),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 0;
                  });
                },
                icon: _currentIndex == 0
                    ? const Icon(
                        Icons.home,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.home,
                        color: Colors.white,
                      )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 1;
                  });
                },
                icon: _currentIndex == 1
                    ? const Icon(
                        Icons.calendar_month,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.calendar_month,
                        color: Colors.white,
                      )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 2;
                  });
                },
                icon: _currentIndex == 2
                    ? const Icon(
                        Icons.mood,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.mood,
                        color: Colors.white,
                      )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 3;
                  });
                },
                icon: _currentIndex == 3
                    ? const Icon(
                        Icons.analytics,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.analytics,
                        color: Colors.white,
                      )),
            IconButton(
                onPressed: () {
                  setState(() {
                    _currentIndex = 4;
                  });
                },
                icon: _currentIndex == 4
                    ? const Icon(
                        Icons.menu,
                        color: Colors.red,
                      )
                    : const Icon(
                        Icons.menu,
                        color: Colors.white,
                      )),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IndexedStack(
          index: _currentIndex,
          children: _pages,
        ),
        bottomNavigationBar: BottomAppBar(
            height: 80,
            shape: const CircularNotchedRectangle(),
            padding: const EdgeInsets.only(bottom: 0, left: 0, right: 0, top: 0),
            elevation: 5,
            color: const Color.fromARGB(255, 219, 221, 220),
            shadowColor: Colors.transparent,
            child: _navigationBar(context)));
  }
}