import 'package:flutter/material.dart';
import 'package:flutter_application_1/first_tab.dart';
import 'package:flutter_application_1/scraped.dart';
import 'package:flutter_application_1/search.dart';
import 'package:flutter_application_1/short.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:line_icons/line_icons.dart';

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  _FirstState createState() => _FirstState();
}

class _FirstState extends State<FirstPage> {
  double deviceWidth = 0.0;
  double deviceHeight = 0.0;
  double centerWidth = 0.0;
  double centerHeight = 0.0;
  double poleHeight = 0.0;
  double imgSize = 48; // 1:1 image

  double topPoint = 0.0;
  double bottomPoint = 0.0;
  double startPoint = 0.0;
  double endPoint = 0.0;

  late final List<Widget> _widgetOptions = <Widget>[
    ShortVideoPlatform(),
    SearchScreen(),
    ScrapScreen(),
  ];

  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addPostFrameCallback((_) {
      setState(() {
        deviceWidth = MediaQuery.of(context).size.width;
        deviceHeight = MediaQuery.of(context).size.height;
        centerWidth = 0.0;
        centerHeight = 0.0;
        poleHeight = deviceWidth * 0.13;

        topPoint = (centerHeight - deviceWidth) * 0.5; // img size = 48
        bottomPoint = topPoint + deviceWidth - poleHeight - imgSize; // img size = 48
        startPoint = 0.0;
        endPoint = startPoint + deviceWidth - imgSize;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Stack(
        children: [
          Scaffold(
            backgroundColor: Colors.white,
            body: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
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
                        icon: LineIcons.video,
                        text: 'Shorts',
                      ),
                      GButton(
                        icon: LineIcons.timesCircle,
                        text: 'Search',
                      ),
                      GButton(
                        icon: LineIcons.heart,
                        text: 'Bookmark',
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
          ),
        ],
      ),
    );
  }
}
