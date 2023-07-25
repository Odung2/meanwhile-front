import 'package:flutter/material.dart';
import 'package:flutter_application_1/first_page.dart';
import 'package:flutter_application_1/main.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dialog_builders.dart';

class KakaoApp extends StatelessWidget {
  const KakaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter App',
      home: WebViewPage(),
    );
  }
}

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});

  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  final url = "https://kauth.kakao.com/oauth/authorize?client_id=54747942f208486425c7e37cb211a42f&redirect_uri=http://172.10.5.81:80/kakao/sign_in&response_type=code";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse(url),
        ),
        initialOptions: InAppWebViewGroupOptions(
            android: AndroidInAppWebViewOptions(useHybridComposition: true)),
        onLoadStop: (controller, url) async {
          if(url.toString().startsWith("http://172.10.5.81:80/kakao")) {
            Uri uri = Uri.parse(url.toString());
            String? data = uri.queryParameters['data'];

            if(data == "" || data == null)
              {
                DialogBuilder(context).showResultDialog('다시 시도해주세요.');
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              }
            else
              {
                storeJwtToken(data);
                await Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const FirstPage()),
                );
              }
          }
        },
      ),
    );
  }

  Future<void> storeJwtToken(String token) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('jwtToken', token);
  }
}