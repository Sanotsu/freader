// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/layout/home_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

const users = {
  'admin': '123',
  'test': '123',
  'admin@gmail.com': '123',
};

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  // 模拟登录等操作执行了1秒钟
  Duration get loginTime => const Duration(milliseconds: 1000);

  // 验证账号密码回调(需要是Future)
  Future<String?> _authUser(LoginData data) {
    return Future.delayed(loginTime).then((_) async {
      if (!users.containsKey(data.name)) {
        return '账号不存在!';
      }
      if (users[data.name] != data.password) {
        return '账号密码不匹配!';
      }

      // 账号密码验证成功之后返回null。
      // 在之前保存账号信息，用于主页显示
      print('Name: ${data.name}, Password: ${data.password}');

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(GlobalConstants.loginAccount, data.name);

      return null;
    });
  }

  // 账号注册
  Future<String?> _signupUser(SignupData data) {
    print(data.toString());

    return Future.delayed(loginTime).then((_) async {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(GlobalConstants.loginAccount, data.name!);

      return null;
    });
  }

  // 重置密码
  Future<String?> _recoverPassword(String name) {
    return Future.delayed(loginTime).then((_) {
      if (!users.containsKey(name)) {
        return '用户不存在!';
      }
      return null;
    });
  }

  // 登入成功后保存登入信息
  Future<void> saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(GlobalConstants.loginState, true);
  }

  /// 自定义用户、密码验证函数
  // 账号验证：不为空即可
  static String? defaultUserValidator(value) {
    if (value!.isEmpty) {
      return '用户名/账号不可为空！';
    }
    return null;
  }

  static String? defaultEmailValidator(value) {
    // 邮箱正则
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

    if (value!.isEmpty || !emailRegex.hasMatch(value)) {
      return '邮箱格式不正确!';
    }
    return null;
  }

  //密码不可为空，最短不少于2位
  static String? defaultPasswordValidator(value) {
    if (value!.isEmpty || value.length <= 2) {
      return '密码过短!';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      /// 从上到下的顺序
      // 图标
      logo: const AssetImage('images/image_page_demo/freader-icon.png'),
      // 标题
      // title: 'FReader',
      // 使用账号/密码（默认是邮箱/密码）
      userType: LoginUserType.name,
      // 账号验证函数
      userValidator: defaultUserValidator,
      // 点击登录按钮触发的函数
      onLogin: _authUser,
      // 点击注册按钮触发的函数
      onSignup: _signupUser,
      // 登录/注册 成功的回调函数
      onSubmitAnimationCompleted: () async {
        // 登入成功，保存登入成功信息之后，再跳转到主页
        saveLoginState();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      },
      // 点击重置密码按钮的回调函数
      onRecoverPassword: _recoverPassword,
      // 登录页面各个按钮标签的文字（不替换就是默认的英文）
      messages: LoginMessages(
        userHint: "账号",
        passwordHint: "密码",
        confirmPasswordHint: "确认密码",
        confirmPasswordError: "账号密码不匹配!",
        loginButton: "登录",
        signupButton: "注册",
        forgotPasswordButton: "忘记密码?",
        recoverPasswordButton: "重置密码",
        goBackButton: "返回",
      ),
    );
  }
}
