import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 新闻模块占位（readhub级别）
///
///

class NewsPageDemo extends StatefulWidget {
  const NewsPageDemo({Key? key}) : super(key: key);

  @override
  State<NewsPageDemo> createState() => _NewsPageDemoState();
}

class _NewsPageDemoState extends State<NewsPageDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("NewsPageDemo"),
        // 2022-05-06 后续可参看 lib\_demos\search_on_app_bar.dart 做readhub的新闻查询。
        actions: <Widget>[
          IconButton(
            iconSize: 20.sp,
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search', // icon的语义标签。
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: const Center(
        child: Text("NewsPageDemo ……"),
      ),
    );
  }
}
