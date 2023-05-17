import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/news_view/news_page_demo.dart';
import 'package:freader/views/news_view/readhub_category/readhub_page.dart';
import 'package:freader/views/news_view/sina_roll_news_category/sina_roll_news_page.dart';
import 'package:freader/views/news_view/zhihu_category/zhihu_page.dart';

/// 2022-05-05
/// 目前支持或计划支持的开源的新闻api，就会放到这个titles中，点击对应的card，跳转到具体网站的页面，查看详情内容

class NewsPage extends StatefulWidget {
  const NewsPage({Key? key}) : super(key: key);

  @override
  State<NewsPage> createState() => _NewsPageState();
}

class _NewsPageState extends State<NewsPage> {
  // 新闻站点
  final titles = [
    "Readhub",
    "知乎日报",
    "新浪滚动新闻",
    // "NewsData",
  ];
  // 站点简述
  final subtitles = [
    "每天三分钟的科技新闻聚合阅读.",
    "每天三次，每次七分钟.",
    "新浪实时热点新闻",
    // "Here is list 3 subtitle"
  ];

  final siteLogos = [
    "images/site_logos/readhub_logo.png",
    "images/site_logos/zhihu_daily_logo.png",
    "images/site_logos/sina_news_logo.png",
    // "images/avatar.png"
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
                leading: SizedBox(
                  width: 60.0.sp,
                  child: Center(
                    child: Image.asset(siteLogos[index]),
                  ),
                ),
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
      screen = const SinaRollNewsPage();
      break;
    default:
      screen = const NewsPageDemo();
  }

  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return screen;
      },
    ),
  );
}
