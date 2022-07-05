import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/utils/global_styles.dart';
import 'package:freader/views/news_view/sina_roll_news_category/sina_roll_news_widget/sina_roll_news.dart';

class SinaRollNewsPage extends StatefulWidget {
  const SinaRollNewsPage({Key? key}) : super(key: key);

  @override
  State<SinaRollNewsPage> createState() => _SinaRollNewsPageState();
}

class _SinaRollNewsPageState extends State<SinaRollNewsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("新浪滚动新闻"),
        actions: <Widget>[
          IconButton(
            iconSize: 20,
            icon: const Icon(
              Icons.search,
              semanticLabel: 'search', // icon的语义标签。
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Center(
          child: Column(
            children: <Widget>[
              Container(
                height: tabContainerHeight,
                color: Colors.brown, // 用來看位置，不需要的话这个Container可以改为SizedBox
                child: TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(
                        width: 3.0.sp, color: Colors.lightBlue), // 下划线的粗度和颜色
                    // 下划线的四边的间距horizontal橫向
                    insets: EdgeInsets.symmetric(horizontal: 2.0.sp),
                  ),
                  indicatorWeight: 0,
                  indicatorSize: TabBarIndicatorSize.label,
                  tabs: [
                    Tab(
                      child: Text(
                        "新浪滚动新闻",
                        style: TextStyle(fontSize: sizeHeadline3),
                      ),
                    ),
                    Tab(
                      child: Text(
                        "占位资讯",
                        style: TextStyle(fontSize: sizeHeadline3),
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: TabBarView(
                  children: <Widget>[
                    Center(
                      child: SinaRollNews(),
                    ),
                    Center(
                      child: Text("Sina占位资讯……"),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
