import 'package:flutter/material.dart';
import 'package:freader/widgets/global_styles.dart';
import 'package:freader/views/news_view/readhub_category/readhub_widget/readhub_typed_news.dart';

class ReadhubPage extends StatefulWidget {
  const ReadhubPage({Key? key}) : super(key: key);

  @override
  State<ReadhubPage> createState() => _ReadhubPageState();
}

class _ReadhubPageState extends State<ReadhubPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Readhub"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => {Navigator.of(context).pop('返回')},
          ),

          //  这里可以整一个actions中的查询
          bottom: TabBar(
            tabs: [
              Tab(
                child: Text(
                  "热门话题",
                  style: TextStyle(fontSize: sizeHeadline3),
                ),
              ),
              Tab(
                child: Text(
                  '科技动态',
                  style: TextStyle(fontSize: sizeHeadline3),
                ),
              ),
              Tab(
                child: Text(
                  '技术资讯',
                  style: TextStyle(fontSize: sizeHeadline3),
                ),
              ),
              Tab(
                child: Text(
                  '区块链',
                  style: TextStyle(fontSize: sizeHeadline3),
                ),
              ),
            ],
          ),
        ),
        body: Column(
          children: const <Widget>[
            Expanded(
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
    ));
  }
}
