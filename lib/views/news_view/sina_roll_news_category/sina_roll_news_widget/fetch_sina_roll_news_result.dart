import 'dart:async';
import 'dart:convert';

import 'package:freader/models/sina_roll_news_result.dart';
import 'package:freader/utils/constant_functions.dart';

import 'package:http/http.dart' as http;

/// 后续可能有所谓的延迟加载数据

// 获取公共数据的方法
Future<SinaRollNewsResultData> fetchSinaRollNewsResult(String url) async {
// url示例：https://api.readhub.cn/topic/list?page=2&size=20

  cusPrintAll(url);

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // cusPrintAll(response.body);

    // 测试时，直接取json的内容进行转换测试
    // var resp = json.decode(response.body)["result"]["data"][0];
    // var data = DataData.fromJson(resp);
    // cusPrintAll("---------->$resp    $data");

    // 原始的json字符串没有大括号包裹
    return SinaRollNewsResultData.fromJson(json.decode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}
