// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/first_page.dart';
// import 'package:flutter_application_1/main.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:async/async.dart';
// import 'package:animated_login/animated_login.dart';
// import 'dialog_builders.dart';
//
// class KakaoApp extends StatelessWidget {
//   const KakaoApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return const MaterialApp(
//       title: 'Flutter App',
//       home: WebViewPage(),
//     );
//   }
// }
//
// class WebViewPage extends StatefulWidget {
//   const WebViewPage({super.key});
//
//   @override
//   State<WebViewPage> createState() => _WebViewPageState();
// }
//
// class _WebViewPageState extends State<WebViewPage> {
//   final url = "https://kauth.kakao.com/oauth/authorize?client_id=61cf0a365da5ecf4a1c4bd3d12aed9ab&redirect_uri=http://168.131.151.213:4040/kakao/sign_in&response_type=code";
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: InAppWebView(
//         initialUrlRequest: URLRequest(
//           url: Uri.parse(url),
//         ),
//         initialOptions: InAppWebViewGroupOptions(
//             android: AndroidInAppWebViewOptions(useHybridComposition: true)),
//         onLoadStop: (controller, url) async {
//           if(url.toString().startsWith("http://168.131.151.213:4040/kakao")) {
//             Uri uri = Uri.parse(url.toString());
//             String? data = uri.queryParameters['data'];
//
//             if(data == "" || data == null)
//               {
//                 print("kakao login not suc");
//                 DialogBuilder(context).showResultDialog('다시 시도해주세요.');
//                 await Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const MyApp()),
//                 );
//               }
//             else
//               {
//                 print("kakao login succeeded");
//                 storeJwtToken(data);
//                 // await Future.delayed(const Duration(seconds: 2));
//                 // Navigator.pop(context);
//                 await Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(builder: (context) => const FirstPage()),
//                 );
//               }
//
//           }
//         },
//       ),
//
//     );
//   }
//
//   Future<void> storeJwtToken(String token) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.setString('jwtToken', token);
//   }
// }