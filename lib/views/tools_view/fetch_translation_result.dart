// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
import 'package:convert/convert.dart';
import 'package:dio/dio.dart';
import 'package:crypto/crypto.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/models/baidu_fanyi_result.dart';
import 'package:freader/utils/constant_functions.dart';
import 'dart:math';

import 'package:http/http.dart' as http;

/// 后续会找更多接口，供切换翻译引擎，取得更优结果

// LibreTranslate 的翻译虽然免费不需要账号和api key，但质量不好说。
// 英译中 ok翻译为"注"等等
Future<Map<String, dynamic>> fetchLibreTranslateResult(
    String text, String source, String target) async {
  var url = "https://translate.argosopentech.com/translate";

  var body = {
    "q": text,
    "source": source,
    "target": target,
    "format": "text",
  };

  var headers = {"Content-Type": "application/json"};

  print(body);

  final response = await http.post(
    Uri.parse(url),
    body: jsonEncode(body),
    headers: headers,
  );

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    // 原始的json字符串没有大括号包裹

    var resp = jsonDecode(response.body);

    print(resp);

    return jsonDecode(response.body);
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}

// 获取baidu翻译的结果
Future<BaiduFanyiResult> fetchBaiduTranslateResult(
  String text,
  String source,
  String target,
) async {
  String commonUrl = "https://fanyi-api.baidu.com/api/trans/vip/translate";

  /// 1 生成签名
  /// appid + q + salt + 密钥 的顺序拼接得到字符串 1。
  /// 对字符串 1 做 MD5 ，得到 32 位小写的 sign。
  String salt = (Random().nextDouble() * 1024 * 1024).floor().toString();

  String temp = GlobalConstants.baiduFanyiApiAppId +
      text +
      salt +
      GlobalConstants.baiduFanyiApiSecretKey;

  String sign = hex.encode(md5.convert(utf8.encode(temp)).bytes);

  /// 2 构建参数
  // var body = {
  //   "q": text,
  //   "from": source,
  //   "to": target,
  //   "appid": GlobalConstants.baiduFanyiApiAppId,
  //   "salt": salt,
  //   "sign": sign
  // };

  // cusPrintAll(body.toString());

  // var headers = {"Content-Type": "application/x-www-form-urlencoded"};

  /// 3 发起请求，处理返回值
  // final response = await http.post(
  //   Uri.parse(url),
  //   body: jsonEncode(body),
  //   headers: headers,
  // );

  /// 2022-07-08 文档说可以用post，但用post会报错：52003 未授权的用户。
  /// 但改为get请求就没问题了，真奇怪
  ///
  var finalUrl =
      "$commonUrl?q=$text&from=$source&to=zh&appid=${GlobalConstants.baiduFanyiApiAppId}&salt=$salt&sign=$sign";
  final response = await http.get(Uri.parse(finalUrl));

  cusPrintAll(finalUrl);

  if (response.statusCode == 200) {
    var resp = jsonDecode(response.body);

    print(resp);

    return BaiduFanyiResult.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data from $commonUrl');
  }
}

// 获取指定文本翻译结果
// text：要翻译的文本
// source：原始语言
// target：要翻译的目标语言
Future<Map<String, String>> fetchTranslationResultDemo(
    String text, String source, String target) async {
  // 有些路径要apikey的，查看文档：https://github.com/LibreTranslate/LibreTranslate#mirrors
  var url = "https://translate.argosopentech.com/translate";

  var body = {
    "q": text,
    "source": source,
    "target": target,
    "format": "text",
  };

  var headers = {"Content-Type": "application/json"};

  print(body);

  ///发起post请求
  Response response =
      await Dio().post(url, data: body, options: Options(headers: headers));

  print("=====================");
  print(response.statusCode);
  print(response.data.toString());
  print(response.data);

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.

    var rst = jsonDecode("[${response.data}]");

    return rst;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load data from $url');
  }
}

///post请求发送json
void postRequestFunction2() async {
  // 有些路径要apikey的，查看文档：https://github.com/LibreTranslate/LibreTranslate#mirrors

  var url = "https://translate.argosopentech.com/translate";

  ///创建Map 封装参数
  var map = {
    "q": "我想杀了你",
    "source": "zh",
    "target": "en",
    "format": "text",
  };

  var headers = {"Content-Type": "application/json"};

  ///发起post请求
  Response response =
      await Dio().post(url, data: map, options: Options(headers: headers));

  print("response>>>>$response");
  print(response.statusCode);
  print(response.data);
}
