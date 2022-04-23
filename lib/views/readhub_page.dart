import 'package:flutter/material.dart';
import 'package:freader/views/readhub_category/readhub_daily.dart';
import 'package:freader/views/readhub_category/readhub_news.dart';
import 'package:freader/views/readhub_category/readhub_tech.dart';
import 'package:freader/views/readhub_category/readhub_topics.dart';

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
              child: const TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(width: 2.0), // 下划线的粗度
                  // 下划线的四边的间距horizontal橫向
                  insets: EdgeInsets.symmetric(horizontal: 2.0),
                ),
                indicatorWeight: 0,
                indicatorSize: TabBarIndicatorSize.label,
                tabs: [
                  Tab(
                    child: Text(
                      "Topics",
                      style: TextStyle(fontSize: 10),
                    ),
                  ),
                  Tab(
                    height: 12,
                    icon: Icon(
                      Icons.home,
                      size: 10,
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Video',
                    ),
                  ),
                  Tab(
                    child: Text(
                      'Video',
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
                    child: ReadhubTopics(),
                  ),
                  Center(
                    child: ReadhubDaily(
                      title: "daily",
                    ),
                  ),
                  Center(
                    child: ReadhubTech(
                      title: "tech",
                    ),
                  ),
                  Center(
                    child: ReadhubNews(
                      title: "news",
                    ),
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
