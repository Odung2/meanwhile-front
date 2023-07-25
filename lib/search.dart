// import 'dart:js_interop';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_inappwebview/flutter_inappwebview.dart';



String baseUrl = "http://172.10.5.81:443";

class Article {
  // final String title;
  final String summary;
  final String publishTime;
  final List<String> references;
  final List<String> refTitle;
  final String imageLink;
  bool isLiked; // 새로 추가된 속성
// Article({required this.title, required this.summary, required this.publishTime, required this.references, required this.imageLink});
  Article({
    required this.summary,
    required this.publishTime,
    required this.references,
    required this.refTitle,
    required this.imageLink,
    // required this.isLiked, // 기본값은 false로 설정
    this.isLiked=false
  });

}

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<Article> _articles = [];

  TextEditingController _searchController = TextEditingController(); // 검색어를 입력받을 컨트롤러
  @override
  void initState() {
    super.initState();
    _fetchArticles();
  }

  // Function to fetch articles from the Spring Boot server
  Future<void> _fetchArticles() async {
    final keywords = _searchController.text; // 검색어 가져오기
    final queryParams = {
      'keywords': keywords.isNotEmpty ? keywords : 'default_keywords_here' // 검색어가 비어있으면 기본 값 전달
    };
    final uri = Uri.http('172.10.5.81:443', '/articles', queryParams); // 쿼리 파라미터를 포함한 URL 생성
    final request = '$baseUrl/articles?keywords="$keywords"';
    try {
      print(request);
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        print(response.body);
        final jsonData = json.decode(response.body);
        List<Article> articles = [];
        for (var item in jsonData) {
          Article article = Article(
            // title: item['articleId'],
            summary: item['summary'],
            publishTime: item['publishTime'],
            references: List<String>.from(item['references'] ?? []),
            refTitle: List<String>.from(item['refTitles'] ?? []),
            imageLink: item['imageLink'],
          );
          articles.add(article);
        }
        setState(() {
          _articles = articles;
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
  Future<void> _searchArticles(String keyword) async {

    final request = '$baseUrl/articles?keywords=$keyword';
    // final request = '$baseUrl/articles';
    try {
      final response = await http.get(Uri.parse(request));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<Article> articles = [];
        for (var item in jsonData) {
          Article article = Article(
              // title: item['title'],
              summary: item['summary'],
              publishTime: item['publishTime'],
              references: item['references'],
              refTitle: item['refTitles'],
              imageLink: item['imageLink']
          );
          articles.add(article);
        }
        setState(() {
          _articles = articles;
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Article Search')),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '검색어를 입력하세요',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          // 검색 버튼
          ElevatedButton(
            onPressed: _fetchArticles,
            child: Text('검색'),
          ),
          // 검색 결과 출력
          Expanded(
            child: _buildTimeline(),
          ),
        ],
      ),
    );
  }


  Widget _buildTimeline() {
    return ListView.builder(
      itemCount: _articles.length,
      itemBuilder: (context, index) {
        final article = _articles[index];
        return Card(
          child: ListTile(
            // title: Text(article.title),
            subtitle: Text(article.summary),
            trailing: Text(article.publishTime),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ArticleDetailsScreen(article: article),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class ArticleDetailsScreen extends StatelessWidget {
  final Article article;

  ArticleDetailsScreen({required this.article});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Article Details'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Title:"N/A"}',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Text('Summary: ${article.summary ?? "N/A"}'),
          Text('Publish Time: ${article.publishTime ?? "N/A"}'),
          SizedBox(height: 16),
          Text(
            'References:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: article.references?.length ?? 0,
              itemBuilder: (context, index) {
                final refTitle = article.refTitle?[index] ?? "N/A";
                final reference = article.references?[index] ?? "N/A";

                return GestureDetector(
                  onTap: () {
                    _openWebView(context, reference);
                  },
                  child: ListTile(
                    title: Text(refTitle),
                    subtitle: Text(reference),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openWebView(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(url: url, article: article),
      ),
    );
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
  // 빈 하트 버튼을 누르면 호출되는 메서드
  void _toggleLike() {
    setState(() {
      widget.article.isLiked =
      !widget.article.isLiked; // 좋아요 상태를 토글(toggle)하여 변경
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Web View'),
        actions: [
          // 빈 하트 버튼 추가
          IconButton(
            icon: Icon(
              widget.article.isLiked
                  ? Icons.favorite // 좋아요 상태인 경우 빨간색 하트 아이콘
                  : Icons.favorite_border, // 좋아요 상태가 아닌 경우 빈 하트 아이콘
              color: widget.article.isLiked
                  ? Colors.red
                  : null, // 좋아요 상태인 경우 빨간색으로 표시
            ),
            onPressed: _toggleLike, // 빈 하트 버튼을 누르면 _toggleLike 메서드 호출
          ),
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