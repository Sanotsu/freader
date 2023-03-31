// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:freader/common/personal/constants.dart';
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:http/http.dart' as http;

/// 2022-05-05 后续这些地址，可以整理一下，统一放置

/// 2022-05-06 pexels请求需要带Authorization的token才能请求。
Map<String, String> requestHeaders = {
  'Authorization': GlobalConstants.pexelsAuthorization
};

/// 获取pexels 编辑精选图片
Future<List<PhotosData>> fetchPexelsApiImageCuratedResult(int page) async {
  // 默认就80张，反正就耗费用户流量
  var url = "https://api.pexels.com/v1/curated?page=$page&per_page=80";

  final response = await http.get(Uri.parse(url), headers: requestHeaders);

  // 1 响应成功，获取到返回的json字符串
  if (response.statusCode == 200) {
    // 原始的json字符串没有大括号包裹
    final jsonString = "[${response.body}]";

    // 2.转成 List<PexelsApiImagesResult>
    List jsonResult = jsonDecode(jsonString);

    // 3 获取其中photos数组即可 ，jsonResult就1个值而已(photos不存在，就空数组)
    return (jsonResult
                .map((e) => PexelsApiImagesResult.fromJson(e))
                .toList())[0]
            .photos ??
        [];
  } else {
    // 请求失败，抛错
    throw Exception('Failed to load data from $url');
  }
}

/// 关键字查询 pexels 的图片
/// 查询条件有：关键字、方向(橫竖)、大小(高清、一般、低画质)、颜色、地区、页码、上一页
/// 目前会用到的就页码和关键字

Future<List<PhotosData>> fetchPexelsApiImageQueryResult(
    String queryParams) async {
  // 调用者传递条件即可
  // var url = "https://api.pexels.com/v1/search/?$queryParams";
  // 2022-06-09 默认中文地区
  var url = "https://api.pexels.com/v1/search/?$queryParams&locale=zh-CN";

  final response = await http.get(Uri.parse(url), headers: requestHeaders);

  // print("******************************");
  // print(response);

  // 1 响应成功，获取到返回的json字符串
  if (response.statusCode == 200) {
    // 原始的json字符串没有大括号包裹
    final jsonString = "[${response.body}]";

    // 2.转成 List<PexelsApiImagesResult>
    List jsonResult = jsonDecode(jsonString);

    // 3 获取其中photos数组即可 ，jsonResult就1个值而已(photos不存在，就空数组)
    return (jsonResult
                .map((e) => PexelsApiImagesResult.fromJson(e))
                .toList())[0]
            .photos ??
        [];
  } else {
    // 请求失败，抛错
    throw Exception('Failed to load data from $url');
  }
}

// 本地json中的photo数据
Future<List<PhotosData>?> getLocalPexelsApiImageJson(int index) async {
  //1. 读取json文件
  String jsonString =
      await rootBundle.loadString("assets/jsons/pexels_api_images_$index.json");

// print(jsonString);

  //2.转成 List<PexelsApiImagesResult>
  List jsonResult = json.decode("[$jsonString]");

// 本地测试数据，只需要 pexels_api_images.json 中 photos 数组的值就好了，jsonResult就1个值而已
  var temp =
      (jsonResult.map((e) => PexelsApiImagesResult.fromJson(e)).toList())[0]
          .photos;

  return temp;
}
