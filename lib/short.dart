import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: ShortVideoPlatform(),
  ));
}

class ShortVideoObject {
  final String title;
  final String imageUrl;

  ShortVideoObject({required this.title, required this.imageUrl});
}

List<ShortVideoObject> videoObjects = [
  ShortVideoObject(
    title: "Title 1",
    imageUrl: "assets/images/among1.png",
  ),
  ShortVideoObject(
    title: "Title 2",
    imageUrl: "assets/images/among2.png",
  ),
  ShortVideoObject(
    title: "Title 3",
    imageUrl: "assets/images/among3.png",
  ),
];

class ShortVideoPlatform extends StatefulWidget {
  @override
  _ShortVideoPlatformState createState() => _ShortVideoPlatformState();
}

class _ShortVideoPlatformState extends State<ShortVideoPlatform> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onDoubleTap: () {
          _scrapCurrentVideo();
        },
        onVerticalDragEnd: (details) {
          _handleVerticalScroll(details.primaryVelocity!);
        },
        child: PageView.builder(
          scrollDirection: Axis.vertical,
          controller: _pageController,
          itemCount: videoObjects.length,
          onPageChanged: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          itemBuilder: (context, index) {
            return AnimatedBuilder(
              animation: _pageController,
              builder: (context, child) {
                double value = 1.0;
                if (_pageController.position.haveDimensions) {
                  value = _pageController.page! - index;
                  value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
                }
                final double verticalOffset = value * 200; // Adjust the vertical offset as needed
                return Center(
                  child: Transform.translate(
                    offset: Offset(0, verticalOffset),
                    child: Opacity(
                      opacity: value,
                      child: Transform.scale(
                        scale: value,
                        child: child,
                      ),
                    ),
                  ),
                );
              },
              child: VideoObjectScreen(videoObject: videoObjects[index]),
            );
          },
        ),
      ),
    );
  }

  void _handleVerticalScroll(double velocity) {
    if (velocity < 0 && _currentIndex < videoObjects.length - 1) {
      setState(() {
        _currentIndex++;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (velocity > 0 && _currentIndex > 0) {
      setState(() {
        _currentIndex--;
      });
      _pageController.animateToPage(
        _currentIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrapCurrentVideo() {
    if (videoObjects.isNotEmpty) {
      setState(() {
        videoObjects.removeAt(_currentIndex);
        if (_currentIndex >= videoObjects.length) {
          _currentIndex = videoObjects.length - 1;
        }
      });
    }
  }
}

class VideoObjectScreen extends StatelessWidget {
  final ShortVideoObject videoObject;

  const VideoObjectScreen({required this.videoObject});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            videoObject.title,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Image.asset(
            videoObject.imageUrl,
            width: 200, // Adjust the image width as needed
            height: 200, // Adjust the image height as needed
          ),
        ],
      ),
    );
  }
}
