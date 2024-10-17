import 'package:code2/modules/account/person_profile_view.dart';
import 'package:code2/modules/cart/history_view.dart';
import 'package:code2/modules/groups/group_view.dart';
import 'package:code2/modules/home/home_view.dart';
import 'package:flutter/material.dart';

import '../../theme.dart';

class OnBoard extends StatefulWidget {
  const OnBoard({super.key});

  @override
  State<OnBoard> createState() => _OnBoardState();
}

class _OnBoardState extends State<OnBoard> {
  int _index = 0;

  List pages = [
    HomeView(),
    GroupView(),
    HistoryView(),
    PersonProfileView(),
  ];

  void onTapIconNav(int index) {
    setState(() {
      _index = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: primaryColor500,
        unselectedItemColor: primaryColor300,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedFontSize: 0.0,
        unselectedFontSize: 0.0,
        currentIndex: _index,
        onTap: onTapIconNav,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.app_registration_sharp),
            label: "sign_up",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "history",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "profile",
          ),
        ],
      ),
    );
  }
}
