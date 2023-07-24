// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/short.dart';
// import 'vertical_timeline.dart';
//
// void main() {
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: const FirstPage(),
//     );
//   }
// }
//
// class FirstPage extends StatelessWidget {
//   const FirstPage({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Center(
//         child: ElevatedButton(
//           onPressed: () {
//             showCustomToast(context, "Hello, this is a custom toast!");
//           },
//           child: Text("Show Custom Toast"),
//         ),
//       ),
//     );
//   }
// }
//
// void showCustomToast(BuildContext context, String message) {
//   final scaffoldMessenger = ScaffoldMessenger.of(context);
//   scaffoldMessenger.removeCurrentSnackBar();
//   scaffoldMessenger.showSnackBar(
//     SnackBar(
//       content: Text(
//         message,
//         textAlign: TextAlign.center,
//         style: const TextStyle(
//           fontFamily: 'mainfont',
//           fontSize: 22.0,
//           color: Colors.white,
//         ),
//       ),
//       duration: const Duration(seconds: 2),
//       backgroundColor: const Color.fromARGB(255, 94, 94, 94),
//     ),
//   );
// }
