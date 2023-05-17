// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/layout/home_page.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:freader/views/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// app 先看是否登录，没有，跳转到 login_screen；已登录，则到home_page。
/// home_page 展示两个底部导航栏在线内容context_online，本地内容context_local，默认展示第一个
///    context_online 的tab显示的page有 news、image、tools
///    context_local 的tab显示的page有 markdown、pdf、txt
///       这两者还带上同一个drawer抽屉组件，也在appbar中显示网络状态

class FreaderApp extends StatelessWidget {
  const FreaderApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 640), // 1080p / 3 ,单位dp
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, widget) {
        return MaterialApp(
          title: 'freader',
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('zh', 'CH'),
            Locale('en', 'US'),
          ],
          locale: const Locale('zh'),
          theme: ThemeData(
            primarySwatch: Colors.blue,
          ),
          home: const MyHomePage(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // 获取登陆信息，如果已经登录，则进入homepage，否则进入登录页面
  bool isLogin = false;

  @override
  void initState() {
    super.initState();
    getLoginState();
  }

  // 获取登陆状态
  Future<void> getLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      // 如果获取的登录状态字符串是 true，则表示登入过；否则就是没有登入过
      isLogin = (prefs.getBool(GlobalConstants.loginState) ?? false);

      print("isLogin-------$isLogin");
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLogin ? const HomePage() : const LoginScreen();
  }
}
