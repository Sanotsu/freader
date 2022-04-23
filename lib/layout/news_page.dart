import 'package:flutter/material.dart';
import 'package:freader/views/readhub_page.dart';

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Center(
        child: Column(
          children: <Widget>[
            Container(
              height: 25,
              color: Colors.blue, // 用來看位置，不需要的话这个Container可以改为SizedBox
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
                      "NewData",
                      style: TextStyle(
                          fontFamily: "BarlowBold",
                          fontSize: 10,
                          color: Colors.black),
                    ),
                  ),
                  Tab(
                    // height: 12,
                    child: Text(
                      "Readhub",
                      style: TextStyle(
                          fontFamily: "BarlowBold",
                          fontSize: 10,
                          color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const Expanded(
              child: TabBarView(
                children: <Widget>[
                  Center(
                    child: Text('imagination coming soon'),
                  ),
                  Center(
                    child: ReadhubPage(),
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
