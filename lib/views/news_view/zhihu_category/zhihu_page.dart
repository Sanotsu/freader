import 'package:flutter/material.dart';
import 'package:freader/views/news_view/zhihu_category/zhihu_widget/zhihu_daily_news.dart';

class ZhihuPage extends StatefulWidget {
  const ZhihuPage({Key? key}) : super(key: key);

  @override
  State<ZhihuPage> createState() => _ZhihuPageState();
}

class _ZhihuPageState extends State<ZhihuPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("知乎日报"),
        // actions: <Widget>[
        //   IconButton(
        //     iconSize: 20,
        //     icon: const Icon(
        //       Icons.search,
        //       semanticLabel: 'search', // icon的语义标签。
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: const ZhihuDailyNews(),

      // 2023-05-17 之前可能预留知乎有多个分类的新闻可读，目前暂只实现知乎日报，所以预留的内容先不用。
      // DefaultTabController(
      //   length: 2,
      //   child: Center(
      //     child: Column(
      //       children: <Widget>[
      //         Container(
      //           height: tabContainerHeight,
      //           color: Colors.brown, // 用來看位置，不需要的话这个Container可以改为SizedBox
      //           child: TabBar(
      //             indicator: UnderlineTabIndicator(
      //               borderSide: BorderSide(
      //                   width: 3.0.sp, color: Colors.lightBlue), // 下划线的粗度和颜色
      //               // 下划线的四边的间距horizontal橫向
      //               insets: EdgeInsets.symmetric(horizontal: 2.0.sp),
      //             ),
      //             indicatorWeight: 0,
      //             indicatorSize: TabBarIndicatorSize.label,
      //             tabs: [
      //               Tab(
      //                 child: Text(
      //                   "占位资讯",
      //                   style: TextStyle(fontSize: sizeHeadline3),
      //                 ),
      //               ),
      //               Tab(
      //                 child: Text(
      //                   "知乎日报",
      //                   style: TextStyle(fontSize: sizeHeadline3),
      //                 ),
      //               ),
      //             ],
      //           ),
      //         ),
      //         const Expanded(
      //           child: TabBarView(
      //             children: <Widget>[
      //               Center(
      //                 child: Text("占位资讯……"),
      //               ),
      //               Center(
      //                 child: ZhihuDailyNews(),
      //               ),
      //             ],
      //           ),
      //         )
      //       ],
      //     ),
      //   ),
      // ),
    );
  }
}
