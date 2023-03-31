// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:freader/models/zhihu_api_daily_result.dart';
import 'package:http/http.dart' as http;

/// 后续可能有所谓的延迟加载数据

// 获取知乎日报的数据，返回一个ZhihuApiDailyResult即可
Future<ZhihuApiDailyResult> fetchZhihuDailyResult(String date) async {
// url示例：https://news-at.zhihu.com/api/3/news/before/20220506

  var url = "https://news-at.zhihu.com/api/3/news/before/$date";

  print("-----------$url");

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    // 原始的json字符串没有大括号包裹
    final json = "[${response.body}]";

    // print(json);

    List resp = jsonDecode(json);

    // print("<<<<<<<<<<<<<<<<<");
    // print(resp);

    return resp.map((e) => ZhihuApiDailyResult.fromJson(e)).toList()[0];
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}
