import 'package:flutter/material.dart';
import 'package:freader/views/news_page_demo.dart';
import 'package:freader/views/readhub_page.dart';
import 'package:freader/views/zhihu_page.dart';

/// 2022-05-05
/// 目前支持或计划支持的开源的新闻api，就会放到这个titles中，点击对应的card，跳转到具体网站的页面，查看详情内容

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // 新闻站点
  final titles = ["Readhub", "ZhiHu", "NewsData", "So on"];
  // 站点简述
  final subtitles = [
    "每天三分钟的科技新闻聚合阅读.",
    "Here is list 2 subtitle",
    "Here is list 2 subtitle",
    "Here is list 3 subtitle"
  ];
  // 站点图标
  final icons = [
    Icons.ac_unit,
    Icons.access_alarm,
    Icons.access_time,
    Icons.access_time
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onCardTap(context, index),
            child: Card(
              child: ListTile(
                title: Text(titles[index]),
                subtitle: Text(subtitles[index]),
                leading: const CircleAvatar(
                  backgroundImage: AssetImage("images/avatar.png"),
                ),
                trailing: Icon(icons[index]),
              ),
            ),
          );
        });
  }
}

_onCardTap(BuildContext context, int index) {
  Widget screen;
  switch (index) {
    case 0:
      screen = const ReadhubPage();
      break;
    case 1:
      screen = const ZhihuPage();
      break;
    case 2:
      screen = const NewsPageDemo();
      break;
    default:
      screen = const ReadhubPage();
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return screen;
      },
    ),
  );
}
