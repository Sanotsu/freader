// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

/// （在用）2022-07-02 markdown_widget是第三方的，有toc，但在drawer点击切换时，老报错
/// 滑动正文的时候也老是报错：
/// ════════ Exception caught by foundation library ════════════════════════════════
/// Null check operator used on a null value

class MarkdownWidgetScreen extends StatefulWidget {
  // md 文件在 asset 中的地址
  final String mdAssetPath;
  const MarkdownWidgetScreen({Key? key, required this.mdAssetPath})
      : super(key: key);

  @override
  State<MarkdownWidgetScreen> createState() => _MarkdownWidgetScreenState();
}

class _MarkdownWidgetScreenState extends State<MarkdownWidgetScreen> {
  Future<String> getLocalPexelsApiImageJson() async {
    String mdString = await rootBundle.loadString(widget.mdAssetPath);
    return mdString;
  }

  final TocController tocController = TocController();

  Widget buildTocWidget() => TocWidget(controller: tocController);

  @override
  void dispose() {
    tocController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 拆取路劲中的文件名称，'assets/mds/demo.md' 中取 demo
    var tempArr = widget.mdAssetPath.split("/");
    String title = tempArr[tempArr.length - 1].split(".")[0];

// 有些文章有带图片，需要相对路径
    List tArr = json.decode(json.encode(tempArr));
    tArr.removeLast();
    String imagesPath = tArr.join("/");

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // leading的返回按钮，是点击上方默认的路由返回按钮会触发，也能传值。优先级高于willPopScope
        // leading: BackButton(
        //   onPressed: () => Navigator.pop(context, "child route data"),
        // ),
      ),
      // 202-05-16 WillPopScope 在点击默认返回的简单图标或者下方的返回按钮，都能触发，并传递值到上一个router
      // 如果没有上面的 AppBar -> leading 的返回，则上方默认返回箭头或者返回键都会触发此。
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          // Navigator.pop(context, "data you want return");
          return false;
        },
        // 如果是内嵌的要用asset，否则读文件
        /// 后续可以把内嵌的，放到app安装时默认生产的文件夹下去，然后再读，进行统一。此处仅用于学习接口
        child: Column(
          children: <Widget>[
            // Expanded(child: buildTocWidget(), flex: 1),
            Expanded(
              // flex: 3,
              child: FutureBuilder(
                future: getLocalPexelsApiImageJson(),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return MarkdownWidget(
                      data: snapshot.data,
                      tocController: tocController,
                      config: MarkdownConfig(configs: [
                        // 代码的样式配置（实测必须```定行，没有缩进才能识别）
                        PreConfig(
                          language: 'ts',
                          textStyle: TextStyle(fontSize: 10.sp),
                        ),
                        // 正文的样式配置
                        PConfig(
                          textStyle: TextStyle(fontSize: 10.sp),
                        ),
                        LinkConfig(
                          style: const TextStyle(
                            color: Colors.red,
                            decoration: TextDecoration.underline,
                          ),
                          onTap: (url) async {
                            var tempUrl = Uri.parse(url);
                            if (await canLaunchUrl(tempUrl)) {
                              await launchUrl(
                                tempUrl,
                                mode: LaunchMode.inAppWebView,
                                webViewConfiguration:
                                    const WebViewConfiguration(
                                  enableJavaScript: true,
                                  enableDomStorage: true,
                                ),
                              );
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                        ),
                        // 各级标题的样式配置
                        H1Config(style: TextStyle(fontSize: 16.sp)),
                        H2Config(style: TextStyle(fontSize: 14.sp)),
                        H3Config(style: TextStyle(fontSize: 12.sp)),
                        H4Config(style: TextStyle(fontSize: 10.sp)),
                        // 使用`code`包装的代码的样式设置
                        CodeConfig(style: TextStyle(fontSize: 10.sp)),
                        // 列表样式配置
                        ListConfig(marginLeft: 32.sp),
                        // 图片配置
                        ImgConfig(
                          builder: (String url, attributes) {
                            // print("============");
                            // print("$imagesPath/$url");
                            return Image.asset("$imagesPath/$url");
                          },
                        )
                      ]),
                    );
                  } else {
                    return const Center(
                      child: Text("加载中..."),
                    );
                  }
                },
              ),
            )
          ],
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 60.sp,
              child: DrawerHeader(
                margin: EdgeInsets.zero,
                padding: EdgeInsets.zero,
                decoration: const BoxDecoration(
                  color: Colors.blue,
                ),
                child: Padding(
                  padding: EdgeInsets.zero,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        "目录",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: buildTocWidget(),
            ),
            SizedBox(
              height: 50.sp,
            ),
          ],
        ),
      ),
    );
  }
}
