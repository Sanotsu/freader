// ignore_for_file: deprecated_member_use, avoid_print, prefer_typing_uninitialized_variables

import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/widgets/global_styles.dart';
import 'package:freader/views/image_view/image_page_demo.dart';
import 'package:freader/views/image_view/pexels_category/pexels_image_page.dart';

class ImagePage extends StatefulWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> with TickerProviderStateMixin {
  // 新闻站点
  final titles = [
    "Pexels",
    // "Unsplash",
    "Asset的图片示例",
  ];
  // 站点简述
  final subtitles = [
    "Free stock photos & videos you can use everywhere.",
    // "Here is list 2 subtitle",
    "demo image page",
  ];

  // 站点图标
  final siteLogos = [
    "images/site_logos/pexels_logo.png",
    // "images/avatar.png",
    "images/avatar.png"
  ];

  // 分类图标
  final icons = [Icons.image, Icons.image, Icons.image, Icons.image];

  late StreamSubscription<ConnectivityResult> subscription;
  //用来显示网络状态的字符串
  String networkStateString = "";

// 获取当前连接的网络
  getState() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      networkStateString = connectivityResult.toString();
    });
  }

  @override
  void initState() {
    super.initState();
    // 初始获取网络连接种类
    getState();

    // 初始就监听网络连接变化，如果进入本页面，使用的不是wifi，才方便弹窗提醒。
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        networkStateString = result.toString();
      });
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        separatorBuilder: (BuildContext context, int index) => const Divider(),
        itemCount: titles.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _onCardTap(context, index, networkStateString),
            child: Card(
              child: ListTile(
                title: Text(titles[index]),
                subtitle: Text(subtitles[index]),
                leading: SizedBox(
                  width: 60.0.sp,
                  child: Image.asset(siteLogos[index]),
                ),
                // trailing: Icon(icons[index]),
              ),
            ),
          );
        });
  }
}

/// 点击卡片，进行页面跳转
_onCardTap(BuildContext context, int index, String networkStateString) {
  Widget screen;

  switch (index) {
    // 如果是点击第1个，为跳转到pexels页面，
    //    如果网络不是wifi环境，先弹窗提醒，用户确定，才跳转；取消则不跳转。
    //    如果是wifi环境，直接跳转，不弹窗。
    case 0:
      if (networkStateString != "ConnectivityResult.wifi") {
        return showConfirmDialog(context, const PexelsImagePage());
      } else {
        screen = const PexelsImagePage();
        break;
      }
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
          style: TextStyle(fontSize: sizeDialogTitle),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text(
                '当前处于数据流量网络,',
                style: TextStyle(fontSize: sizeDialogContent),
              ),
              Text(
                '浏览pexels的图片会消耗大量流量,确定继续浏览图片资源?',
                style: TextStyle(fontSize: sizeDialogContent),
              ),
            ],
          ),
        ),
        actions: <Widget>[
          // 点击取消，保持在当前页面
          TextButton(
            child: Text(
              '取消',
              style: TextStyle(
                fontSize: sizeDialogButton,
              ),
            ),
            onPressed: () {
              Navigator.pop(ctx);
            },
          ),
          // 点击确认，则跳转到新的页面
          TextButton(
            child: Text(
              '确定',
              style: TextStyle(
                fontSize: sizeDialogButton,
              ),
            ),
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
