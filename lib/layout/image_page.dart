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
// 弹出对话框(区分点击tab标签或者下方滑动屏幕切换tabview的索引)
  void showConfirmDialog(int newIndex, {bool isTap = true}) {
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
                if (isTap) {
                  Navigator.of(context).pop();
                } else {
                  // 索引0是本地demo图片tabview。
                  _tabController.index = 0;
                  Navigator.pop(context);
                }
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
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() {
        setState(() {
          if (_tabController.indexIsChanging) {
            print("11111111111111111当前的tab index is ${_tabController.index}");
          }
          // 外层的判断避免使用tab切换是触发两次。（区分tab点击和滑动切换了tabview的index。）
          if (_tabController.index.toDouble() ==
              _tabController.animation!.value) {
            if (_tabController.index == 1) {
              showConfirmDialog(_tabController.index, isTap: false);
              // _tabController.index = _tabController.previousIndex;
            }
          }
        });
      });
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
                  // 点击tap的操作（如果有tabController侦听器，可以不使用onTap侦听了。因为前者tap和滑动切换了index都可以监听到）
                  // onTap: (index) {
                  //   // 如果点击的index是1，现在为pexels tab，则弹窗提示是否继续
                  //   if (index == 1) {
                  //     showConfirmDialog(_tabController.index);
                  //     // set TabBar index to previous one(this will allow TabBar to stay on the same tab):
                  //     // 在dialog中点击确认，则修改tab的index，取消就保留在当前tab
                  //     _tabController.index = _tabController.previousIndex;
                  //   }
                  //   print("图片tabBar 当前的index是 $index");
                  // },
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
