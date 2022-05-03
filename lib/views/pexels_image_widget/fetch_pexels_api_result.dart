// ignore_for_file: avoid_print

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:http/http.dart' as http;

//...
Future<Map<String, dynamic>> parseJsonFromAssets(String assetsPath) async {
  print('--- Parse json from: $assetsPath');
  return rootBundle
      .loadString(assetsPath)
      .then((jsonStr) => jsonDecode(jsonStr));
}

// 网络数据（有qps限制，开发时先用本地的）
Future<List<PexelsApiImagesResult>> fetchPexelsApiImageResult(
    String url) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // 原始的json字符串没有大括号包裹
    final json = "[" + response.body + "]";

    List resp = jsonDecode(json);

    // print("<<<<<<<<<<<<<<<<<");
    // print(resp);

    return resp.map((e) => PexelsApiImagesResult.fromJson(e)).toList();
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
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
  List jsonResult = json.decode("[" + jsonString + "]");

// 本地测试数据，只需要 pexels_api_images.json 中 photos 数组的值就好了，jsonResult就1个值而已
  var temp =
      (jsonResult.map((e) => PexelsApiImagesResult.fromJson(e)).toList())[0]
          .photos;

  return temp;
}
