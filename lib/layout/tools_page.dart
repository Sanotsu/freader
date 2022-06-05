import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/news_page_demo.dart';
import 'package:freader/views/readhub_page.dart';
import 'package:freader/views/tools_category/today_in_history_screen.dart';
import 'package:freader/views/zhihu_page.dart';

/// 2022-05-05
/// 目前支持或计划支持的开源的新闻api，就会放到这个titles中，点击对应的card，跳转到具体网站的页面，查看详情内容

class ToolsPage extends StatefulWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  // 新闻站点
  final titles = [
    "历史上的今天",
    "随机笑话段子",
    "随机静动图片",
    "近期天气预报",
  ];
  // 站点简述
  final subtitles = [
    "历史上今天发生地一些大事情.",
    "每天三次，每次七分钟.",
    "Here is list 2 subtitle",
    "Here is list 3 subtitle"
  ];

  final bgImages = [
    "images/tools_image/历史上的今天.png",
    "images/site_logos/zhihu_daily_logo.png",
    "images/avatar.png",
    "images/avatar.png"
  ];

  // 站点图标
  final icons = [
    Icons.newspaper,
    Icons.newspaper,
    Icons.newspaper,
    Icons.newspaper,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50.sp,
          child: Center(
            child: Text(
              "实用工具主页",
              style: TextStyle(fontSize: 20.sp),
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              childAspectRatio: 16 / 9, // item的宽高比
              crossAxisCount: 2,
            ),
            itemCount: titles.length,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () => _onCardTap(context, index),
                child: Card(
                  semanticContainer: true,
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  child: Image.asset(
                    bgImages[index],
                    fit: BoxFit.fill,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10.sp),
                ),
                // Card(
                //   color: const Color.fromARGB(255, 197, 204, 202),
                //   child: ListTile(
                //     title: Text(titles[index]),
                //     subtitle: Text(subtitles[index]),
                //   ),
                // ),
              );
            },
          ),
        ),
      ],
    );
  }
}

_onCardTap(BuildContext context, int index) {
  Widget screen;
  switch (index) {
    case 0:
      screen = const TodayInHistoryScreen();
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