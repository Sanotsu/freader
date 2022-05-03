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
// 弹出对话框
  void showConfirmDialog(int newIndex) {
    showDialog<bool>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
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
            // 点击取消，保持在当前tab
            TextButton(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            // 点击确认，则跳转到新的tab
            TextButton(
              child: const Text('确定'),
              onPressed: () {
                _tabController.index = newIndex;
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

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
                child: TabBar(
                  indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(width: 2.0.sp), // 下划线的粗度
                    // 下划线的四边的间距horizontal橫向
                    insets: EdgeInsets.symmetric(horizontal: 2.0.sp),
                  ),
                  indicatorWeight: 0,
                  indicatorSize: TabBarIndicatorSize.label,
                  controller: _tabController,
                  // 点击tap的操作
                  onTap: (index) {
                    // 如果点击的index是1，现在为pexels tab，则弹窗提示是否继续
                    if (index == 1) {
                      showConfirmDialog(_tabController.index);
                      // set TabBar index to previous one(this will allow TabBar to stay on the same tab):
                      // 在dialog中点击确认，则修改tab的index，取消就保留在当前tab
                      _tabController.index = _tabController.previousIndex;
                    }
                    print("图片tabBar 当前的index是 $index");
                  },
                  tabs: [
                    Tab(
                      child: Text(
                        "DemoImage",
                        style: TextStyle(
                            fontFamily: "BarlowBold",
                            fontSize: 10.sp,
                            color: Colors.black),
                      ),
                    ),
                    Tab(
                      // height: 12,
                      child: Text(
                        "Pexels",
                        style: TextStyle(
                            fontFamily: "BarlowBold",
                            fontSize: 10.sp,
                            color: Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: const <Widget>[
                    Center(
                      child: ImagePageDemo(),
                    ),
                    Center(
                      child: PexelsImagePage(),
                    ),
                  ],
                ),
              )
            ],
          ),
        ));
  }
}

class PexelsTabView extends StatelessWidget {
  const PexelsTabView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
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
                    "DemoImage",
                    style: TextStyle(
                        fontFamily: "BarlowBold",
                        fontSize: 10,
                        color: Colors.black),
                  ),
                ),
                Tab(
                  // height: 12,
                  child: Text(
                    "Pexels",
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
                  child: ImagePageDemo(),
                ),
                Center(
                  child: PexelsImagePage(),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
