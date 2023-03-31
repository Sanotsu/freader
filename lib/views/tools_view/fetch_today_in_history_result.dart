// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:freader/models/today_in_history_result.dart';
import 'package:http/http.dart' as http;

/// 后续可能有所谓的延迟加载数据

// 获取历史上的今天的数据，返回一个该结构的List
Future<List<TodayInHistoryResultData>> fetchTodayInHistoryResult() async {
  var url = "https://api.asilu.com/today";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    // 原始的json字符串没有大括号包裹
    final json = "[${response.body}]";
    List resp = jsonDecode(json);

    TodayInHistoryResult temp =
        resp.map((e) => TodayInHistoryResult.fromJson(e)).toList()[0];
    return temp.data;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}
