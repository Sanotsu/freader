// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:flutter/services.dart' show rootBundle;
// import 'package:markdown_widget/config/highlight_themes.dart' as theme;
// 代码高亮等使用的样式
import 'package:flutter_highlight/themes/a11y-light.dart';

class MarkdownPageScreen extends StatefulWidget {
  const MarkdownPageScreen({Key? key}) : super(key: key);

  @override
  State<MarkdownPageScreen> createState() => _MarkdownPageScreenState();
}

class _MarkdownPageScreenState extends State<MarkdownPageScreen> {
  Future<String> getLocalPexelsApiImageJson() async {
    String mdString = await rootBundle
        .loadString('assets/md/typescript-handbook-overview.md');
    return mdString;
  }

  final TocController tocController = TocController();

  Widget buildTocWidget() => TocWidget(controller: tocController);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("demo"),
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
            // Expanded(child: buildMarkdown(), flex: 3),
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
                          const PreConfig(
                              theme: a11yLightTheme, language: 'dart'),
                          PConfig(
                            textStyle: TextStyle(fontSize: 10.sp),
                          ),
                          H1Config(style: TextStyle(fontSize: 16.sp)),
                          H2Config(style: TextStyle(fontSize: 14.sp)),
                          H3Config(style: TextStyle(fontSize: 12.sp)),
                          H4Config(style: TextStyle(fontSize: 10.sp)),
                        ])
                        // config: MarkdownConfig(
                        //   // 正文的样式配置
                        //   pConfig: PConfig(
                        //     textStyle: TextStyle(fontSize: 10.sp),
                        //     selectable: true,
                        //   ),
                        //   // 无序列表的样式配置（有序列表是olConfig）
                        //   ulConfig: UlConfig(
                        //     textStyle: TextStyle(fontSize: 10.sp),
                        //   ),
                        //   // 各级标题的样式配置
                        //   titleConfig: TitleConfig(
                        //     h1: TextStyle(fontSize: 16.sp),
                        //     h2: TextStyle(fontSize: 14.sp),
                        //     h3: TextStyle(fontSize: 12.sp),
                        //     h4: TextStyle(fontSize: 10.sp),
                        //   ),
                        //   // 代码的样式配置（实测必须```定行，没有缩进才能识别）
                        //   preConfig: PreConfig(
                        //     language: 'ts',
                        //     textStyle: TextStyle(fontSize: 10.sp),
                        //     theme: theme.a11yLightTheme,
                        //   ),
                        // ),
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
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: buildTocWidget(),
      ),
    );
  }
}
