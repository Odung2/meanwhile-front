import 'dart:core';
import 'package:flutter/material.dart';
import 'package:flutter_application_1/first_tab.dart';
import 'package:flutter_application_1/short.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

void main() {
  runApp(MaterialApp(
    home: FirstPage(),
  ));
}


class FirstPage extends StatefulWidget {
  const FirstPage({super.key});

  @override
  _FirstState createState() => _FirstState();
}

class _FirstState extends State<FirstPage> {

  late double deviceWidth = MediaQuery.of(context).size.width;  // 화면의 가로 크기
  late double deviceHeight = MediaQuery.of(context).size.height; // 화면의 세로 크기
  late double centerWidth = 0.0;
  late double centerHeight = 0.0;
  late double poleHeight = deviceWidth*0.13;
  double imgSize = 48; // 1:1 image

  late final topPoint = (centerHeight - deviceWidth)*0.5; // img size = 48
  late final bottomPoint = topPoint + deviceWidth - poleHeight - imgSize; // img size = 48
  late final startPoint = 0.0;
  late final endPoint = startPoint + deviceWidth - imgSize;

  late final List<Widget> _widgetOptions = <Widget>[
    ShortVideoPlatform(),
    VerticalTimeline(),
  ];

  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
          children:[
            Scaffold(
              backgroundColor: Colors.white,
              body: LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (Widget child, Animation<double> animation) {
                        return FadeTransition(opacity: animation, child: child);
                      },
                      child: _widgetOptions.elementAt(_selectedIndex),
                    ),
                  );
                },
              ),
              // ),
              bottomNavigationBar: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 0, 0, 0),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 20,
                      color: Colors.black.withOpacity(.1),
                    )
                  ],
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8),
                    child: GNav(
                      rippleColor: const Color.fromARGB(255, 0, 0, 0),
                      hoverColor: const Color.fromARGB(255, 96, 69, 69),
                      gap: 8,
                      activeColor: const Color.fromARGB(255, 0, 0, 0),
                      iconSize: 24,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      duration: const Duration(milliseconds: 400),
                      tabBackgroundColor: Colors.grey[100]!,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      tabs: const [
                        GButton(
                          icon: LineIcons.coins,
                          text: 'Bank',
                        ),
                        GButton(
                          icon: LineIcons.wallet,
                          text: 'ATM',
                        ),
                        GButton(
                          icon: LineIcons.store,
                          text: 'Market',
                        ),
                      ],
                      selectedIndex: _selectedIndex,
                      onTabChange: (index) {
                        setState(() {
                          _selectedIndex = index;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),]
      ),
    );
  }
}