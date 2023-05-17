import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/ble_view/simple_blue_screen.dart';
import 'package:freader/views/news_view/news_page_demo.dart';
import 'package:freader/views/tools_view/random_network_photo_screen.dart';
import 'package:freader/views/tools_view/today_in_history_screen.dart';
import 'package:freader/views/tools_view/multilingual_translation_screen.dart';

/// 2022-05-05
/// 目前支持或计划支持的开源的新闻api，就会放到这个titles中，点击对应的card，跳转到具体网站的页面，查看详情内容

class ToolsPage extends StatefulWidget {
  const ToolsPage({Key? key}) : super(key: key);

  @override
  State<ToolsPage> createState() => _ToolsPageState();
}

class _ToolsPageState extends State<ToolsPage> {
  // 各个区块功能名称
  final titles = [
    "历史上的今天",
    "随机网络图片",
    "多国语言翻译",
    "低功蓝牙示例",
  ];

// 这个背景 图的长度，要和下面gridview的builder中 itemCount 一致
  final bgImages = [
    "images/tools_image/历史上的今天.png",
    "images/tools_image/随机网络图片.png",
    "images/tools_image/多国语言翻译.png",
    "images/tools_image/ToBeContinue.png"
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  elevation: 5,
                  margin: EdgeInsets.all(10.sp),
                  color: Colors.green[300],
                  shadowColor: Colors.blue,
                  // child: Image.asset(
                  //   bgImages[index],
                  //   fit: BoxFit.fill,
                  // ),
                  child: Center(
                    child: Text(
                      titles[index],
                      style: TextStyle(fontSize: 20.sp),
                    ),
                  ),
                ),
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
      screen = const RandomNetworkPhotoScreen();
      break;
    case 2:
      screen = const MultilingualTranslationScreen();
      break;
    case 3:
      screen = const SimpleBlueScreen();
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
