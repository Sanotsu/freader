import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'layout/app.dart';

// void main() {
//   runApp(const FreaderApp());
// }
Future<void> main() async {
  FlutterError.onError = (details) async {
    if (kDebugMode) {
      /// 将错误输出到控制台
      FlutterError.dumpErrorToConsole(details);
    } else {
      /// 将Framework的异常转发到当前Zone的onError回调中
      Zone.current.handleUncaughtError(details.exception, details.stack!);
    }
  };

  runApp(const FreaderApp());
}
