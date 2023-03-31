// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';

import 'package:freader/models/readhub_api_result.dart';
import 'package:freader/models/readhub_api_topic_detail.dart';
import 'package:http/http.dart' as http;

/// 后续可能有所谓的延迟加载数据

// 获取公共数据的方法
Future<List<ReadhubApiResult>> fetchReadhubApiCommonResult(String url) async {
// url示例：https://api.readhub.cn/topic/list?page=2&size=20

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    // 原始的json字符串没有大括号包裹
    final json = "[${response.body}]";

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

/// 获取指定【热门话题】的详情
Future<List<ReadhubApiTopicDetailData>> fetchReadhubTopicDetailResult(
    String url) async {
// url示例： https://api.readhub.cn/topic/8fxcBjoRnWX

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    // 原始的json字符串没有大括号包裹
    // 因为这里返回的就是 ReadhubApiTopicDetail 中 ReadhubApiTopicDetailData 的数据了
    final json = "[${response.body}]";

    List resp = jsonDecode(json);

    // print("<<<<<<<<<<<<<<<<<");
    // print(resp);

    // 所以这里直接转json的为 ReadhubApiTopicDetailData 而不是 ReadhubApiTopicDetail
    return resp.map((e) => ReadhubApiTopicDetailData.fromJson(e)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}
