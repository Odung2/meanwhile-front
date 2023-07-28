import 'dart:convert';
import 'dart:ffi';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:url_launcher/url_launcher.dart';

String baseUrl = "http://172.10.5.81:443";

final defaultTextStyle = TextStyle(
  fontFamily: 'line',
  fontSize: 16,
);

class Bookmark {
  final String refLink;
  final String refTitle;
  final int bookmarkId;

  Bookmark({required this.refLink, required this.refTitle, required this.bookmarkId});

  factory Bookmark.fromJson(Map<String, dynamic> json) {
    return Bookmark(
      refLink: json['refLink'],
      refTitle: json['refTitle'],
      bookmarkId:json['bookmarkId'],
    );
  }
}
//

class ScrapScreen extends StatefulWidget {
  @override
  _ScrapScreenState createState() => _ScrapScreenState();
}

class _ScrapScreenState extends State<ScrapScreen> {

  void updateBookmarks() {
    fetchBookmarks();
  }

  Future<String?> getJwtToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }

  Future<List<Bookmark>> fetchBookmarks() async {
    final jwtToken = await getJwtToken();
    final request =  Uri.parse("$baseUrl/bookmarks");
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken'
    };
    var response = await http.get(request, headers:headers);
    var json = jsonDecode(response.body);
    List<Bookmark> bookmarks = [];
    // for(var bookmarkJson in json)
    // {
    //   bookmarks.add(Bookmark.fromJson(bookmarkJson));
    // }
    setState(() {
      for(var bookmarkJson in json)
      {
        bookmarks.add(Bookmark.fromJson(bookmarkJson));
      }
    });
    return bookmarks;

  }

  Future<void> deleteBookmark(Bookmark bookmark) async {
    final jwtToken = await getJwtToken();
    final headers = <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $jwtToken',
    };
    final body = jsonEncode({ 'bookmarkId': bookmark.bookmarkId,'refLink': bookmark.refLink, 'refTitle': bookmark.refTitle});

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/delete_bookmark'),
        headers: headers,
        body: body,
      );

      if (response.statusCode == 200) {
        print('Bookmark deleted successfully');
        // TODO: 서버에서 삭제한 항목에 대한 응답 처리 (필요시 추가 구현)
      } else {
        print('Failed to delete bookmark: ${response.statusCode}');
        // TODO: 실패 시 에러 처리 (필요시 추가 구현)
      }
    } catch (e) {
      print('Error occurred while deleting bookmark: $e');
      // TODO: 에러 처리 (필요시 추가 구현)
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, height *0.02, 0, height *0.02),
                  child: Text(

                    "My bookmark list 😽",
                    style: TextStyle(

                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          FutureBuilder<List<Bookmark>>(
            future:fetchBookmarks(),
            builder: (BuildContext context, AsyncSnapshot<List<Bookmark>> snapshot){
              if(snapshot.hasData) {
                List<Bookmark> bookmarks = snapshot.data!;
                return ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: bookmarks.length,
                  itemBuilder: (BuildContext context, int index) {
                    final item = bookmarks[index];
                    return GestureDetector(
                      onTap: ()  {
                      },
                      child: Container(
                        width: width*0.9,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          children: [
                            const SizedBox(height: 8),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start, // Adjust crossAxisAlignment
                              children: [
                                Flexible(
                                  child: GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => WebViewScreen(url: item.refLink),
                                        ),
                                      );
                                    },
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${item.refTitle}",
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        SizedBox(height: height * 0.005),
                                        Text(
                                          "${item.refLink}",
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    FontAwesomeIcons.twitter,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    _shareOnTwitter(item.refLink, item.refTitle);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete),
                                  onPressed: () async {
                                    final confirmDelete = await showDialog<bool>(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("항목 삭제"),
                                          content: Text("해당 항목을 삭제하시겠습니까?"),
                                          actions: [
                                            TextButton(
                                              child: Text("취소"),
                                              onPressed: () {
                                                Navigator.of(context).pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: Text("삭제"),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirmDelete == true) {
                                      // 삭제 확인 후, 항목 삭제 로직을 실행합니다.
                                      deleteBookmark(item); // 삭제 함수 호출
                                      setState(() {
                                        bookmarks.removeAt(index); // 리스트에서 항목 삭제
                                      });
                                    }
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }
              else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {
                return CircularProgressIndicator();
              }
            }
          ),
            ],
          )
        )
      ],
    );
  }

  void _shareOnTwitter(String reference, String refTitle) async {
    // String textToshare = '안녕하세요, 트위터 공유하기 테스트입니다!';
    String tweetText = "쿠케케켁..트위터공유하기성공\n$refTitle\n$reference"; // Customize the tweet text as desired
    String twitterUrl = "https://twitter.com/intent/tweet?text=${Uri.encodeComponent(tweetText)}";
    if (await canLaunch(twitterUrl)) {
      await launch(twitterUrl);
    } else {
      // Handle error if Twitter app or website cannot be launched
      print("Error launching Twitter");
    }
  }

}


class WebViewScreen extends StatefulWidget {
  // final Article article;
  // final bool isLiked;
  final String url;

  WebViewScreen({required this.url});

  @override
  _WebViewScreenState createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  // final Article article;
  late InAppWebViewController _webViewController;

  // bool _isHeartFilled = false; // 빈 하트 버튼의 상태를 나타내는 변수
  @override
  void initState() {
    super.initState();
    // print("Article article title: ${widget.article.refTitle}");
    // print("Article Liked State: ${widget.article.isLiked}");
  }
  // 빈 하트 버튼을 누르면 호출되는 메서드
  // void _toggleLike() {
  //   setState(() {
  //     widget.article.isLiked =
  //     !widget.article.isLiked; // 좋아요 상태를 토글(toggle)하여 변경
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web View'),
        actions: [
          // 빈 하트 버튼 추가
          // IconButton(
          //   icon: Icon(
          //     widget.article.isLiked
          //         ? Icons.favorite // 좋아요 상태인 경우 빨간색 하트 아이콘
          //         : Icons.favorite_border, // 좋아요 상태가 아닌 경우 빈 하트 아이콘
          //     color: widget.article.isLiked
          //         ? Colors.red
          //         : null, // 좋아요 상태인 경우 빨간색으로 표시
          //   ),
          //   onPressed: _toggleLike, // 빈 하트 버튼을 누르면 _toggleLike 메서드 호출
          // ),
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


