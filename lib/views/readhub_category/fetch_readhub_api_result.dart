// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:freader/models/readhub_api_result.dart';
import 'package:http/http.dart' as http;

/// 后续可能有所谓的延迟加载数据

// 获取公共数据的方法
Future<List<ReadhubApiResult>> fetchReadhubApiCommonResult(
    String url) async {
// url示例：https://api.readhub.cn/topic/list?page=2&size=20

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    // 原始的json字符串没有大括号包裹
    final json = "[" + response.body + "]";

    List resp = jsonDecode(json);

    // print("<<<<<<<<<<<<<<<<<");
    // print(resp);

    return resp.map((e) => ReadhubApiResult.fromJson(e)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}
