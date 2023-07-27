import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const String url = "http://172.10.5.135:443";

void main() {
  runApp(MaterialApp(
    home: ShortVideoPlatform(),
  ));
}

class ShortVideoObject {
  final String title;
  final String summary;
  final String url;
  final String refs;
  final String date;

  ShortVideoObject({
    required this.title,
    required this.summary,
    required this.url,
    required this.refs,
    required this.date,
  });

  factory ShortVideoObject.fromJson(Map<String, dynamic> json) {
    return ShortVideoObject(
      title: json['title'],
      url: json['url'],
      summary: json['summary'],
      refs: json['refs'],
      date: json['date'],
    );
  }
}

Future<List<ShortVideoObject>> fetchVideoObjects() async {
  final response = await http.get(Uri.parse('$url/trending'));

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return List<ShortVideoObject>.from(
      data.map((item) => ShortVideoObject.fromJson(item)),
    );
  } else {
    throw Exception('Failed to load video objects');
  }
}

class ShortVideoPlatform extends StatefulWidget {
  @override
  _ShortVideoPlatformState createState() => _ShortVideoPlatformState();
}

class _ShortVideoPlatformState extends State<ShortVideoPlatform> {
  late PageController _pageController;
  int _currentIndex = 0;
  List<ShortVideoObject> videoObjects = [];
  bool isLoading = true;

  Future<void> fetchVideoData() async {
    try {
      List<ShortVideoObject> data = await fetchVideoObjects();
      setState(() {
        videoObjects = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching video data: $e');
      isLoading = false;
    }
  }

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    fetchVideoData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: (){

        },
        onDoubleTap: () {
          _scrapCurrentVideo();
        },
        onVerticalDragEnd: (details) {
          _handleVerticalScroll(details.primaryVelocity!);
        },
        child: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : PageView.builder(
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
                final double verticalOffset = value * 200;
                return Center(
                  child: Transform.translate(
                    offset: Offset(0, 0),
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
    print("double tap!!");
  }
}

class VideoObjectScreen extends StatelessWidget {
  final ShortVideoObject videoObject;

  const VideoObjectScreen({required this.videoObject});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double desiredHeight = (screenHeight / 4) * 3;

    return Stack(
          children: [
                Positioned(
                  top: 0,
                  child: Container(
                    width: screenWidth,
                    height: desiredHeight,
                    child: _buildImage(),
                  ),
                ),
            Positioned(
              top: desiredHeight,
              child: Container(
                width: screenWidth,
                padding: EdgeInsets.all(8.0),
                child: Text(
                  videoObject.title,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 100, // Set a large number of lines
                  overflow: TextOverflow.ellipsis, // Allow text to wrap with \n if it overflows
                ),
              ),
            ),
            // Other widgets below the image and title
          ],
    );
  }

  Widget _buildImage() {
    if (videoObject.url.startsWith("http")) {
      return Image.network(
        videoObject.url,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/images/demo.png", // Replace "demo.png" with the actual asset image path
        fit: BoxFit.cover,
      );
    }
  }

}
