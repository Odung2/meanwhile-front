import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: Text('트위터 공유하기')),
        body: Center(
          child: ElevatedButton(
            onPressed: () {
              _launchTwitter();
            },
            child: Text('트위터로 공유하기'),
          ),
        ),
      ),
    );
  }

  // 트위터 공유 기능 실행
  void _launchTwitter() async {
    final String twitterUrl = 'https://twitter.com/intent/tweet?text=테스트 메시지';

    // 트위터 앱이 설치되어 있는 경우 앱을 엽니다.
    if (await canLaunch(twitterUrl)) {
      await launch(twitterUrl);
    } else {
      // 트위터 앱이 설치되어 있지 않은 경우 웹 브라우저를 통해 트위터 공유 페이지를 엽니다.
      await launch(twitterUrl, forceSafariVC: false);
    }
  }
}
//원하는 text 미리 띄우기
// void _launchTwitter() async {
//   final String textToShare = '안녕하세요, 트위터 공유하기 테스트입니다!';
//   final String twitterUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(textToShare)}';
//
//   // ...
// }

//url, 이미지 함께 공유하기
// void _launchTwitter() async {
//   final String textToShare = '트위터 공유하기 테스트입니다!';
//   final String urlToShare = 'https://example.com';
//   final String imageUrlToShare = 'https://example.com/image.jpg';
//   final String hashtagsToShare = 'flutter,dart,example';
//
//   final String twitterUrl = 'https://twitter.com/intent/tweet?text=${Uri.encodeComponent(textToShare)}&url=${Uri.encodeComponent(urlToShare)}&hashtags=${Uri.encodeComponent(hashtagsToShare)}';
//
//   // ...
// }
