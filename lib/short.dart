import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

const String baseUrl = "http://172.10.5.81:443";
bool showFloatingImage = false;

final defaultTextStyle = TextStyle(
  fontFamily: 'line',
  fontSize: 16,
);

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
  final response = await http.get(Uri.parse('$baseUrl/trending'));

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

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIndex);
    fetchVideoData();
  }

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
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        children: [
          // Fixed text at the top
          Container(
            height: height*0.02,
          ),
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'News Reels 😽',
              style: TextStyle(
                fontSize: 24,
                color: Colors.blueAccent,
                fontWeight: FontWeight.bold,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          Expanded(
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
                child: GestureDetector(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => WebViewScreen(url: videoObjects[_currentIndex].refs),
                            ),
                          );
                        },
                        onDoubleTap: () {
                          _scrapCurrentVideo();
                        },
                  child: Container(child: VideoObjectScreen(videoObject: videoObjects[index])),
                ));
              },
            ),
          ),
        ],
      ),
    );
  }


  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: GestureDetector(
  //       onTap: (){
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => WebViewScreen(url: videoObjects[_currentIndex].refs),
  //           ),
  //         );
  //       },
  //       onDoubleTap: () {
  //         _scrapCurrentVideo();
  //       },
  //       onVerticalDragEnd: (details) {
  //         _handleVerticalScroll(details.primaryVelocity!);
  //       },
  //       child: isLoading
  //           ? Center(
  //         child: CircularProgressIndicator(),
  //       )
  //           : PageView.builder(
  //         scrollDirection: Axis.vertical,
  //         controller: _pageController,
  //         itemCount: videoObjects.length,
  //         onPageChanged: (index) {
  //           setState(() {
  //             _currentIndex = index;
  //           });
  //         },
  //         itemBuilder: (context, index) {
  //           return AnimatedBuilder(
  //             animation: _pageController,
  //             builder: (context, child) {
  //               double value = 1.0;
  //               if (_pageController.position.haveDimensions) {
  //                 value = _pageController.page! - index;
  //                 value = (1 - (value.abs() * 0.5)).clamp(0.0, 1.0);
  //               }
  //               final double verticalOffset = value * 200;
  //               return Center(
  //                 child: Transform.translate(
  //                   offset: Offset(0, 0),
  //                   child: Opacity(
  //                     opacity: value,
  //                     child: Transform.scale(
  //                       scale: value,
  //                       child: child,
  //                     ),
  //                   ),
  //                 ),
  //               );
  //             },
  //             child: VideoObjectScreen(videoObject: videoObjects[index]),
  //           );
  //         },
  //       ),
  //     ),
  //   );
  // }

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
    setState(() {
      showFloatingImage = true;
    });
    sendLikeData(videoObjects[_currentIndex].title, videoObjects[_currentIndex].refs);
    Timer(Duration(seconds: 2), () {
      setState(() {
        showFloatingImage = false;
      });
    });
  }
}

class VideoObjectScreen extends StatefulWidget {
  final ShortVideoObject videoObject;

  const VideoObjectScreen({required this.videoObject});

  @override
  _VideoObjectScreenState createState() => _VideoObjectScreenState();
}

class _VideoObjectScreenState extends State<VideoObjectScreen> {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double desiredHeight = (screenHeight / 4) * 3;

    return Stack(
          children: [
            Column(
              children: [
                Container(
                  width: screenWidth,
                  height: desiredHeight,
                  child: _buildImage(),
                ),
                Flexible(
                  // width: screenWidth,
                  // padding: EdgeInsets.all(8.0),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      widget.videoObject.title,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        overflow: TextOverflow.ellipsis,
                      ),
                      maxLines: 100, // Set a large number of lines
                      overflow: TextOverflow.ellipsis, // Allow text to wrap with \n if it overflows
                    ),
                  ),
                ),
              ],
            ),
        if (showFloatingImage)
          Positioned(
            top: desiredHeight/2,
            left: desiredHeight/15,
            child: AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(seconds: 1),
              child: Image.asset(
                "assets/images/like.gif",
                width: 300,
                height: 300,
              ),
            ),
          ),
        // Other widgets below the image and title
      ],
    );
  }

  Widget _buildImage() {
    if (widget.videoObject.url.startsWith("http")) {
      return Image.network(
        widget.videoObject.url,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/images/demo.png",
        fit: BoxFit.cover,
      );
    }
  }
}

class WebViewScreen extends StatefulWidget {
  final String url;

  WebViewScreen({required this.url});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web View'),
        actions: [
        ],
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: Uri.parse(widget.url)),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useOnLoadResource: true,
            mediaPlaybackRequiresUserGesture: false,
          ),
        ),
        onWebViewCreated: (controller) {
          _webViewController = controller;
          // _addButtonInWebView();
        },
      ),
    );
  }
}

Future<void> sendLikeData(String refTitle, String refLink) async {
  final url = '$baseUrl/add_bookmark'; // 좋아요 정보를 전송할 엔드포인트 URL
  final String? jwtUtilToken = await getJwtToken();

  final requestData = {
    // 'jwtUtilToken': jwtUtilToken,
    'refTitle': refTitle,
    'refLink': refLink,
  };
  print(requestData);
  print(json.encode(requestData));
  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $jwtUtilToken'
      },
      body: json.encode(requestData), // 데이터를 JSON 형태로 인코딩하여 요청에 추가
    );

    if (response.statusCode == 200) {
      // 서버로부터 성공적인 응답을 받은 경우
      print('Like data sent successfully!');
    } else {
      // 서버로부터 실패 응답을 받은 경우
      print('Failed to send like data. Error: ${response.statusCode}');
    }
  } catch (e) {
    // 예외가 발생한 경우
    print('Error: $e');
  }
}

Future<String?> getJwtToken() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('jwtToken');
}
