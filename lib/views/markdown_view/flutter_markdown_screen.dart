// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// 2022-07-02 flutter_markdown是flutter官方的，但是没有toc，没有目录

class FlutterMarkdownScreen extends StatefulWidget {
  // md 文件在 asset 中的地址
  final String mdAssetPath;
  const FlutterMarkdownScreen({Key? key, required this.mdAssetPath})
      : super(key: key);

  @override
  State<FlutterMarkdownScreen> createState() => _FlutterMarkdownScreenState();
}

class _FlutterMarkdownScreenState extends State<FlutterMarkdownScreen> {
  @override
  Widget build(BuildContext context) {
    // 拆取路劲中的文件名称，'assets/mds/demo.md' 中取 demo
    var tempArr = widget.mdAssetPath.split("/");
    String title = tempArr[tempArr.length - 1].split(".")[0];

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        // leading的返回按钮，是点击上方默认的路由返回按钮会触发，也能传值。优先级高于willPopScope
        // leading: BackButton(
        //   onPressed: () => Navigator.pop(context, "child route data"),
        // ),
      ),
      // 202-05-16 WillPopScope 在点击默认返回的简单图标或者下方的返回按钮，都能触发，并传递值到上一个router
      // 如果没有上面的 AppBar -> leading 的返回，则上方默认返回箭头或者返回键都会触发此。
      body: WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          // Navigator.pop(context, "data you want return");
          return false;
        },
        // 如果是内嵌的要用asset，否则读文件
        /// 后续可以把内嵌的，放到app安装时默认生产的文件夹下去，然后再读，进行统一。此处仅用于学习接口
        child: FutureBuilder(
          // future: getLocalPexelsApiImageJson(),
          future: DefaultAssetBundle.of(context).loadString(widget.mdAssetPath),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (snapshot.hasData) {
              return Markdown(
                data: snapshot.data,
                selectable: true,
                styleSheet: MarkdownStyleSheet(
                  blockSpacing: 4.0.sp,
                  h1: TextStyle(fontSize: 14.sp),
                  h2: TextStyle(fontSize: 12.sp),
                  h3: TextStyle(fontSize: 10.sp),
                  p: TextStyle(fontSize: 8.sp), // 正文部分字体大小
                  pPadding: EdgeInsets.all(1.0.sp),
                  code: TextStyle(fontSize: 8.sp),
                  listBulletPadding: EdgeInsets.all(1.0.sp),
                ),
              );
            } else {
              return const Center(
                child: Text("加载中..."),
              );
            }
          },
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

// 获取内置的md文件
  Future<String> getLocalPexelsApiImageJson() async {
    String mdString = await rootBundle.loadString('assets/mds/demo.md');
    return mdString;
  }
}

// 底部菜单
Widget _buildBottomNavigationBar() {
  return BottomAppBar(
    color: Colors.lightBlue,
    shape: const CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
    child: SizedBox(
      height: 40.sp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 书签
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: Colors.black,
              size: 25.sp,
            ),
            onPressed: () {},
          ),
          // 放大
          IconButton(
            icon: Icon(
              Icons.zoom_in,
              color: Colors.black,
              size: 25.sp,
            ),
            onPressed: () {},
          ),
        ], //均分底部导航栏横向空间
      ),
    ),
  );
}
