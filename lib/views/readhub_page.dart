import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/readhub_category/readhub_typed_news.dart';

class ReadhubPage extends StatefulWidget {
  const ReadhubPage({Key? key}) : super(key: key);

  @override
  State<ReadhubPage> createState() => _ReadhubPageState();
}

class _ReadhubPageState extends State<ReadhubPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 20,
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
                      "热门话题",
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '科技动态',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '技术资讯',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '区块链',
                      style: TextStyle(fontSize: 10.sp),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              // 虽然是四个页面，但可以抽出通用的小组件复用
              child: TabBarView(
                children: <Widget>[
                  Center(
                    child: ReadhubTypedNews(newsType: 'topics'),
                  ),
                  Center(
                    child: ReadhubTypedNews(newsType: '1'),
                  ),
                  Center(
                    child: ReadhubTypedNews(newsType: '2'),
                  ),
                  Center(
                    child: ReadhubTypedNews(newsType: '3'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
