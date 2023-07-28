// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String baseUrl = "http://172.10.5.81:443";


class Article {
  // final String title;
  final String summary;
  final String publishTime;
  final List<String> references;
  final List<String> refTitle;
  final String imageLink;
  final List<bool> isLiked;
  final int langauge;
// Article({required this.title, required this.summary, required this.publishTime, required this.references, required this.imageLink});
  Article({
    required this.summary,
    required this.publishTime,
    required this.references,
    required this.refTitle,
    required this.imageLink,
    required this.langauge,
    List<bool>? isLiked,
  }): isLiked = List.filled(refTitle.length, false); // Initialize isLiked with all false values if isLiked is not provided;

}

class LikeStatus {
  final String refTitle;
  bool isLiked;

  LikeStatus({required this.refTitle, required this.isLiked});
}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> _articles = [];
  List<Article> _koreanArticles = [];
  List<Article> _allArticles = [];
  List<Article> _englishArticles = [];
  int _selectedLanguage = 0; // 0 for Korean, 1 for English, and 2 for All

  TextEditingController _searchController = TextEditingController(); // 검색어를 입력받을 컨트롤러
  @override
  void initState() {
    super.initState();
    // _fetchArticles();
  }

  // Function to fetch articles from the Spring Boot server
  Future<void> _fetchArticles(String keywords) async {
    // final keywords = _searchController.text; // 검색어 가져오기
    // final keywords = keywords; // 검색어 가져오기

    print(keywords);
    final queryParams = {
      'keywords': keywords.isNotEmpty ? keywords : 'default_keywords_here' // 검색어가 비어있으면 기본 값 전달
    };

    final uri = Uri.http('172.10.5.81:443', '/search', queryParams); // 쿼리 파라미터를 포함한 URL 생성
    // final uri = Uri.http('127.0.0.1:8080', '/articles', queryParams); // 쿼리 파라미터를 포함한 URL 생성

    final request = '$baseUrl/search?query="$keywords"';
    try {
      print(request);
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        print(response);
        final jsonData = json.decode(response.body);
        print("jsondata");
        print(jsonData);
        List<Article> articles = [];
        for (var item in jsonData) {
          Article article = Article(
            // title: item['articleId'],
            summary: item['summary'],
            publishTime: item['publishTime'],
            references: List<String>.from(item['references'] ?? []),
            refTitle: List<String>.from (item['refTitles'] ?? []),
            imageLink: item['imageLink'],
            langauge: item['language'],
          );
          articles.add(article);
        }
        print(articles);
        setState(() {
          _articles = articles;
          _koreanArticles = articles.where((article) => article.langauge == 0).toList();
          _allArticles = articles;
          _englishArticles = articles.where((article) => article.langauge == 1).toList();
        });
      } else {
        // Handle error if the server request fails
        print('Failed to fetch articles. Error: ${response.statusCode}');
      }
    } catch (e) {
      // Handle any other errors that may occur during the request
      print('Error: $e');
    }
  }

  // Function to search articles on Spring Boot server
  // Future<void> _searchArticles(String keyword) async {
  //
  //   final request = '$baseUrl/articles?keywords=$keyword';
  //   // final request = '$baseUrl/articles';
  //   try {
  //     final response = await http.get(Uri.parse(request));
  //     if (response.statusCode == 200) {
  //       final jsonData = json.decode(response.body);
  //       List<Article> articles = [];
  //       for (var item in jsonData) {
  //         Article article = Article(
  //             // title: item['title'],
  //             summary: item['summary'],
  //             publishTime: item['publishTime'],
  //             references: item['references'],
  //             refTitle: item['refTitles'],
  //             imageLink: item['imageLink']
  //         );
  //         articles.add(article);
  //       }
  //       setState(() {
  //         _articles = articles;
  //       });
  //     } else {
  //       // Handle error if the server request fails
  //       print('Failed to fetch articles. Error: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     // Handle any other errors that may occur during the request
  //     print('Error: $e');
  //   }
  // }


  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      // appBar: AppBar(title: Text('Article Search')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // 검색창
            Container(
              height: height*0.05,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.fromLTRB(10, height *0.02, 0, height *0.02),
                child: Text(
                  "Search topic 😽",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(3.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: '검색어를 입력하세요',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (keyword) async {
                  await _fetchArticles(keyword); // 검색 수행
                },
              ),
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex:1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your onPressed logic for Button 1 here
                      setState(() {
                        _selectedLanguage = 0;
                      });
                    },
                    child: Text('국내 언론'),
                    style: ElevatedButton.styleFrom(
                      primary: _selectedLanguage == 0 ? Colors.blueGrey : Colors.white24,
                    ),
                  ),
                  // style: ElevatedButton.styleFrom(
                  //   primary: _selectedLanguage == 0 ? Colors.blue : null,
                  // ),
                ),
                Expanded(
                  flex:1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your onPressed logic for Button 1 here
                      setState(() {
                        _selectedLanguage = 2;
                      });
                    },
                    child: Text('통합'),
                    style: ElevatedButton.styleFrom(
                      primary: _selectedLanguage == 2 ? Colors.blueGrey : Colors.white24,
                    ),

                  ),
                ),
                Expanded(
                  flex:1,
                  child: ElevatedButton(
                    onPressed: () {
                      // Add your onPressed logic for Button 2 here
                      setState(() {
                        _selectedLanguage = 1;
                      });
                    },
                    child: Text('외신'),
                    style: ElevatedButton.styleFrom(
                      primary: _selectedLanguage == 1 ? Colors.blueGrey : Colors.white24,
                    ),
                  ),
                ),
              ],
            ),
            // 검색 결과 출력
            Expanded(
              child: FutureBuilder(
                future: Future.value(_articles),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasData) {
                    // 데이터가 있을 경우 ListView.builder로 검색 결과 표시
                    return _buildTimeline(_articles);
                  } else {
                    // 데이터가 없을 경우 빈 화면 표시
                    return Center(child: Text('검색 결과가 없습니다.'));
                  }
                },
              ),
            ),
            // Expanded(
            //   child: _buildTimeline(),
            // ),
          ],
        ),
      ),
    );
  }


  Widget _buildTimeline(_articles) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    List<Article> displayedArticles;

    if (_selectedLanguage == 0) {
      displayedArticles = _koreanArticles;
    } else if (_selectedLanguage == 1) {
      displayedArticles = _englishArticles;
    } else {
      displayedArticles = _allArticles;
    }


    return ListView.builder(
      // itemCount: _articles.length,
      itemCount: displayedArticles.length,
      itemBuilder: (context, index) {
        // final article = _articles[index];
        final article = displayedArticles[index];
        final alignment = article.langauge ==0
            ? Alignment.centerLeft
            : Alignment.centerRight;
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                  builder: (context) => ArticleDetailsScreen(article: article),
                  ),
                );
              },
              child: Container(
                width: width,
                alignment: alignment == Alignment.centerLeft
                  ? Alignment.centerLeft
                  : Alignment.centerRight,
                child: Card(
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(

                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment:alignment == Alignment.centerLeft
                          ? CrossAxisAlignment.start
                          :  CrossAxisAlignment.end,
                        children: [
                          Text(
                            "${article.summary}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(
                            height: height*0.01,
                          ),
                          Text(
                            "${article.publishTime}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          // Text(
                          //   " 참고 기사 더보기",
                          //   style: const TextStyle(
                          //     // fontWeight: FontWeight.bold,
                          //     fontSize: 12,
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}


class ArticleDetailsScreen extends StatefulWidget {
  final Article article;

  ArticleDetailsScreen({required this.article});

  @override
  _ArticleDetailsScreenState createState() => _ArticleDetailsScreenState();
}
// List<LikeStatus> _likeStatusList = [];

class _ArticleDetailsScreenState extends State<ArticleDetailsScreen> {

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height*0.05,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: width,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      // Text(
                      //   '요약문',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     fontSize: 24,
                      //   ),
                      // ),
                      Text(
                        '─── ･ ｡ﾟ☆: *.☽ .* :☆ﾟ. ───',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${widget.article.summary}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Publish Time: ${widget.article.publishTime ?? "N/A"}',
                        style: TextStyle(
                          // fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
                Text(
                  '요약문을 만들 때 참고한 기사 보기 🥸',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.article.references?.length ?? 0,
              itemBuilder: (context, index) {
                final refTitle = widget.article.refTitle?[index] ?? "N/A";
                final reference = widget.article.references?[index] ?? "N/A";
                final isLiked = widget.article.isLiked[index];

                return GestureDetector(
                  onTap: () {
                    _openWebView(context, reference);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      child: Column(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                refTitle,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(reference),
                              SizedBox(height: 8),
                            ],
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                  color: isLiked ? Colors.red : null,
                                ),
                                onPressed: () {
                                  _toggleLike(index);
                                },
                              ),
                              IconButton(
                                icon: Icon(
                                  FontAwesomeIcons.twitter,
                                  color: Colors.blue,
                                ),
                                onPressed: () {
                                  _shareOnTwitter(reference, refTitle);
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  )
                  // ListTile(
                  //   title: Text(refTitle),
                  //   subtitle: Text(reference),
                  //   trailing: Row(
                  //     mainAxisSize: MainAxisSize.min,
                  //     children: [
                  //       IconButton(
                  //         icon: Icon(
                  //           isLiked
                  //               ? Icons.favorite
                  //               : Icons.favorite_border,
                  //           color: isLiked ? Colors.red : null,
                  //         ),
                  //         onPressed: () {
                  //           _toggleLike(index);
                  //         },
                  //       ),
                  //       IconButton(
                  //         icon: Icon(
                  //           FontAwesomeIcons.twitter,
                  //           color: Colors.blue,
                  //         ),
                  //         onPressed: () {
                  //           _shareOnTwitter(reference, refTitle);
                  //         },
                  //       ),
                  //     ],
                  //   ),
                  // ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<String?> getJwtToken() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwtToken');
  }
  // ... 이전 코드 생략 ...
  void _openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url, article: widget.article),
      ),
    );
  }


  void _toggleLike(int index) async {
    setState(() {
      widget.article.isLiked[index] = !widget.article.isLiked[index]; // 해당 요소의 좋아요 상태를 토글(toggle)하여 변경
    });
    if(widget.article.isLiked[index]){
      // 유저의 jwtUtilToken과 해당 refTitle, references 정보를 서버에 전송
      final jwtToken = await getJwtToken();
      final refTitle = widget.article.refTitle[index];
      final references = widget.article.references[index];
      print("before sendlikedata");
      sendLikeData(jwtToken, refTitle, references);
    }

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
  final Article article;
  // final bool isLiked;
  final String url;

  WebViewScreen({required this.url, required this.article});

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
    print("Article article title: ${widget.article.refTitle}");
    print("Article Liked State: ${widget.article.isLiked}");
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

Future<void> sendLikeData(String? jwtUtilToken, String refTitle, String refLink) async {
  final url = '$baseUrl/add_bookmark'; // 좋아요 정보를 전송할 엔드포인트 URL

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