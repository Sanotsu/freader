import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/hitokoto_result.dart';
import 'package:http/http.dart' as http;

class HitokotoSentence extends StatefulWidget {
  const HitokotoSentence({Key? key}) : super(key: key);

  @override
  State<HitokotoSentence> createState() => _HitokotoSentenceState();
}

class _HitokotoSentenceState extends State<HitokotoSentence> {
  //每次获取的数据列表要展示的数据
  late Future<HitokotoResultData> futureReadhubApiResult;

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureReadhubApiResult = fetchHitokotoSentenceResult();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: FutureBuilder<HitokotoResultData>(
          future: futureReadhubApiResult,
          builder: (BuildContext context,
              AsyncSnapshot<HitokotoResultData> snapshot) {
            //请求完成
            if (snapshot.connectionState == ConnectionState.done) {
              Widget textWidget;

              //发生错误
              if (snapshot.hasError) {
                textWidget = Text(snapshot.error.toString());
              }

              if (snapshot.hasData) {
                // 获取hitokoto 一言 对象
                var data = snapshot.data;

                textWidget = Card(
                  margin:
                      EdgeInsets.only(left: 30.0.sp, top: 30.sp, right: 30.sp),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("一言",
                          maxLines: 20,
                          style: TextStyle(
                              fontSize: 12.0.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.green)),
                      Divider(
                        thickness: 1.sp, // 分割线厚度
                        indent: 20.sp, // 分割线前方空白长度
                        color: Colors.red, // 分割线颜色
                      ),
                      Text(
                        "${data!.hitokoto}",
                        style: TextStyle(fontSize: 12.sp),
                        textAlign: TextAlign.start,
                      ),
                      Text(
                        "《${data.from}》- ${data.from_who}",
                        style: TextStyle(
                            fontSize: 10.sp,
                            height: 3.sp), // 字体的height，是字体大小的倍数。
                        textAlign: TextAlign.end,
                      ),
                    ],
                  ),
                );

                return Column(
                  children: [
                    textWidget,
                  ],
                );
              }

              // 发生错误或者有数据会显示对应内容，其他情况则只显示一个占位的组件
              return Column(
                children: [
                  Container(),
                ],
              );
            }
            //请求未完成时弹出loading
            return const CircularProgressIndicator();
          }),
    );
  }
}

/// 获取指定【热门话题】的详情
Future<HitokotoResultData> fetchHitokotoSentenceResult() async {
  /// 类型：哲学、诗词、文学
  String url = "https://v1.hitokoto.cn/?c=k&c=i&c=d";

  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    // 返回的原始json字符串，先转成json，再转成对应的model

    // print(response.body);

    return HitokotoResultData.fromJson(jsonDecode(response.body));
  } else {
    throw Exception('Failed to load data from $url');
  }
}
