import 'package:flutter/material.dart';
import 'package:animated_login/animated_login.dart';
import 'package:async/async.dart';
import 'dialog_builders.dart';

import 'login_functions.dart' as logIn;

/// Main function.
void main() {
  runApp(const MyApp());
}

/// Example app widget.
class MyApp extends StatelessWidget {
  /// Main app widget.
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Animated Login',
      theme: ThemeData(
          primarySwatch:
          ColorService.createMaterialColor(const Color.fromARGB(101, 0, 0, 0))
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/login',
      routes: {
        '/login': (BuildContext context) => const LoginScreen(),
      },
    );
  }
}

/// Example login screen
class LoginScreen extends StatefulWidget {
  /// Simulates the multilanguage, you will implement your own logic.
  /// According to the current language, you can display a text message
  /// with the help of [LoginTexts] class.
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  /// Example selected language, default is English.
  // LanguageOption language = _languageOptions[1];

  /// Current auth mode, default is [AuthMode.login].
  AuthMode currentMode = AuthMode.login;

  CancelableOperation? _operation;

  @override
  Widget build(BuildContext context) {
    return AnimatedLogin(
      onLogin: (LoginData data) async =>
          _authOperation(logIn.LoginFunctions(context).onLogin(data)),
      onSignup: (SignUpData data) async =>
          _authOperation(logIn.LoginFunctions(context).onSignup(data)),
      // onForgotPassword: _onForgotPassword,
      logo: Image.asset('assets/images/logo.gif',),
      backgroundImage: 'assets/images/loginbackground.jpg',
      signUpMode: SignUpModes.both,
      socialLogins: _socialLogins(context),
      loginDesktopTheme: _desktopTheme,
      loginMobileTheme: _mobileTheme,
      loginTexts: _loginTexts,
      initialMode: currentMode,
      onAuthModeChange: (AuthMode newMode) async {
        currentMode = newMode;
        await _operation?.cancel();
      },
    );
  }

  Future<String?> _authOperation(Future<String?> func) async {
    await _operation?.cancel();
    _operation = CancelableOperation.fromFuture(func);
    final String? res = await _operation?.valueOrCancellation();
    if (_operation?.isCompleted == true) {
      DialogBuilder(context).showResultDialog(res ?? '$res.');
    }
    return res;
  }

  LoginViewTheme get _desktopTheme => _mobileTheme.copyWith(
    // To set the color of button text, use foreground color.
    actionButtonStyle: ButtonStyle(
      foregroundColor: MaterialStateProperty.all(Colors.white),
    ),
    dialogTheme: const AnimatedDialogTheme(
      languageDialogTheme: LanguageDialogTheme(
          optionMargin: EdgeInsets.symmetric(horizontal: 80)),
    ),
    loadingSocialButtonColor: const Color(0xFF130101),
    loadingButtonColor: Colors.white,
    privacyPolicyStyle: const TextStyle(fontFamily: "line", color: Color(0xFF130101)),
    privacyPolicyLinkStyle: const TextStyle(fontFamily: "line",
        color: Color(0xFF130101), decoration: TextDecoration.underline),
  );

  /// You can adjust the colors, text styles, button styles, borders
  /// according to your design preferences for *MOBILE* view.
  /// You can also set some additional display options such as [showLabelTexts].
  LoginViewTheme get _mobileTheme => LoginViewTheme(
    logoSize: const Size(500, 400),
    welcomeTitleStyle: const TextStyle(
      fontFamily: "line",
      fontWeight: FontWeight.bold,
      fontSize: 40,
    ),
    welcomeDescriptionStyle: const TextStyle(
      fontFamily: "line",
      fontWeight: FontWeight.bold,
      fontSize: 30,
    ),
    changeActionTextStyle: const TextStyle(
      fontFamily: "line",
      fontSize: 20,
    ),
    useEmailStyle: const TextStyle(
      fontFamily: "line",
      fontSize: 18,
    ),
    actionButtonStyle: ButtonStyle(
        foregroundColor: MaterialStateProperty.all(const Color(0xFF130101)),
        textStyle: MaterialStateProperty.all<TextStyle>(
            const TextStyle(
              fontFamily: "line",
              fontSize: 25,
            )
        )
    ),
    textFormStyle: const TextStyle(
      color: Colors.black87,
    ),
    showLabelTexts: false,
    backgroundColor: const Color(0xFFFFDF66), // const Color(0xFF6666FF),
    formFieldBackgroundColor: Colors.white,
    formWidthRatio: 60,
    // actionButtonStyle: ButtonStyle(
    //   foregroundColor: MaterialStateProperty.all(Color(0xFF130101)),
    // ),
    animatedComponentOrder: const <AnimatedComponent>[
      AnimatedComponent(
        component: LoginComponents.logo,
        animationType: AnimationType.right,
      ),
      AnimatedComponent(component: LoginComponents.title),
      AnimatedComponent(component: LoginComponents.description),
      AnimatedComponent(component: LoginComponents.formTitle),
      AnimatedComponent(component: LoginComponents.socialLogins),
    ],
    privacyPolicyStyle: const TextStyle(fontFamily: "line", color: Colors.white70),
    privacyPolicyLinkStyle: const TextStyle(fontFamily: "line",
        color: Colors.white, decoration: TextDecoration.underline),
  );

  LoginTexts get _loginTexts => LoginTexts(
    nameHint: _username,
    login: _login,
    signUp: _signup,
    welcomeBack: "한편 한국에서는",
    welcomeBackDescription: "세계에서\n보는\n한국",
    welcome: "한편 한국에서는",
    welcomeDescription: "세계에서\n보는\n한국",
  );

  /// You can adjust the texts in the screen according to the current language
  /// With the help of [LoginTexts], you can create a multilanguage scren.
  String get _username => '이름을 입력해주세요';

  String get _login => '로그인';

  String get _signup => '가입하기';

  /// Social login options, you should provide callback function and icon path.
  /// Icon paths should be the full path in the assets
  /// Don't forget to also add the icon folder to the "pubspec.yaml" file.

  List<SocialLogin> _socialLogins(BuildContext context) => <SocialLogin>[
    SocialLogin(
        callback: () async => _socialCallback('Kakao'),
        iconPath: 'assets/images/kakao4.png'),
  ];

  Future<String?> _socialCallback(String type) async {
    await _operation?.cancel();
    _operation = CancelableOperation.fromFuture(
        logIn.LoginFunctions(context).socialLogin(type));
    final String? res = await _operation?.valueOrCancellation();
    return res;
  }
}

class ColorService {
  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}