// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/image_page_demo.dart';
import 'package:freader/views/pexels_image_page.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with TickerProviderStateMixin {
  // 新闻站点
  final titles = ["demo image page", "Pexels", "Unsplash", "So on"];
  // 站点简述
  final subtitles = [
    "demo image page",
    "Free stock photos & videos you can use everywhere.",
    "Here is list 2 subtitle",
    "Here is list 3 subtitle"
  ];

  // 站点图标
  final siteLogos = [
    "images/avatar.png",
    "images/site_logos/pexels_logo.png",
    "images/avatar.png",
    "images/avatar.png"
  ];

  // 分类图标
  final icons = [Icons.image, Icons.image, Icons.image, Icons.image];

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
                  child: Image.asset(siteLogos[index]),
                ),
                trailing: Icon(icons[index]),
              ),
            ),
          );
        });
  }
}

/// 点击卡片，进行页面跳转
_onCardTap(BuildContext context, int index) {
  Widget screen;

  switch (index) {
    case 0:
      screen = const ImagePageDemo();
      break;
    // 如果是点击第二个，为跳转到pexels页面，先弹窗提醒，用户确定，才跳转；取消则不跳转。
    case 1:
      return showConfirmDialog(context, const PexelsImagePage());
    case 2:
      screen = const ImagePageDemo();
      break;
    default:
      screen = const ImagePageDemo();
  }

  // 非特殊情況，跳转到指定页面
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return screen;
      },
    ),
  );
}

/// 显示确认弹窗
/// dialog中点击确认则跳转，点击取消则不跳转。
/// 传入上下文和要跳转的页面【例如: PexelsImagePage()】
void showConfirmDialog(context, routePage) {
  showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext ctx) {
      return AlertDialog(
        title: Text(
          '温馨提醒',
          style: TextStyle(fontSize: 16.sp),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                '浏览pexels的图片会消耗大量流量,',
                style: TextStyle(fontSize: 14.sp),
              ),
              Text(
                '即便连入wifi也是如此,确定继续浏览图片资源?',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          // 点击取消，保持在当前页面
          TextButton(
            child: const Text('取消'),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
          // 点击确认，则跳转到新的页面
          TextButton(
            child: const Text('确定'),
            onPressed: () {
              // 跳转新页面之前，先关闭dialog
              Navigator.of(ctx).pop();
              Navigator.push(
                ctx,
                MaterialPageRoute(builder: (context) => routePage),
              );
            },
          ),
        ],
      );
    },
  );
}
