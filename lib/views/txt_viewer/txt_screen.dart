// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart' show rootBundle;

class TxtScreen extends StatefulWidget {
  final String title;

  const TxtScreen({Key? key, required this.title}) : super(key: key);

  @override
  State<TxtScreen> createState() => _TxtScreenState();
}

class _TxtScreenState extends State<TxtScreen> {
  // txt文本的全部內容
  var txtFullContent = "";
  // 页面标题
  var appTitle = "";
  // 是否在加载文件中
  var txtLoading = false;

  loadTxtData(filename) async {
    setState(() {
      txtLoading = true;
    });

    // 如果是默认，要修改名称
    appTitle = widget.title;

    switch (filename) {
      case "A Dream of Red Mansions":
        filename = "A_Dream_of_Red_Mansions-utf8";
        break;
      case "The Journey to the West":
        filename = "The_Journey_to_the_West-utf8";
        break;
      case "Water Margin":
        filename = "Water_Margin-utf8";
        break;
      case "Romance of the Three Kingdoms":
        filename = "Romance_of_the_Three_Kingdoms-utf8";
        break;
      default:
        filename = "A_Dream_of_Red_Mansions-utf8";
        appTitle = "A_Dream_of_Red_Mansions";
        break;
    }

    var t1 = DateTime.now();
    final data = await rootBundle.loadString('assets/txts/$filename.txt');
    var t2 = DateTime.now();
    print(t2.difference(t1).inMilliseconds); // 时间差 单位毫秒

    setState(() {
      txtFullContent = data;
      txtLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();

    loadTxtData(widget.title);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          appTitle,
          style: TextStyle(fontSize: 20.sp),
        ),
      ),
      body: txtLoading
          ? buildLoadingWidget()
          : NotificationListener<ScrollUpdateNotification>(
              child: ListView(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            // 因为是demo，這個字符串得好几兆，加载自然是慢的
                            Text(
                              txtFullContent,
                              style: TextStyle(fontSize: 14.sp),
                            )
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              onNotification: (notification) {
                //How many pixels scrolled from pervious frame
                print(notification.scrollDelta);

                //List scroll position
                print(notification.metrics.pixels);
                return false;
              },
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }
}

Widget buildLoadingWidget() {
  return Center(
    child: Padding(
      padding: EdgeInsets.all(5.0.sp),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            '加载中...',
            style: TextStyle(fontSize: 8.0.sp),
          ),
          SizedBox(
            height: 15.sp,
            width: 15.sp,
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Colors.blue),
              // value: .7,  /// 加了value是不会转的
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _buildBottomNavigationBar() {
  return BottomAppBar(
    color: Colors.lightBlue,
    child: SizedBox(
      height: 45.sp,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 书签
          IconButton(
            icon: Icon(
              Icons.bookmark,
              color: Colors.white,
              size: 30.sp,
            ),
            onPressed: () {},
          ),
          // 放大
          IconButton(
            icon: Icon(
              Icons.zoom_in,
              color: Colors.white,
              size: 30.sp,
            ),
            onPressed: () {},
          ),
          // 縮小
          IconButton(
            icon: Icon(
              Icons.zoom_out,
              color: Colors.white,
              size: 30.sp,
            ),
            onPressed: () {},
          ),
          // 切换方向

          // 上一页
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_left,
              color: Colors.white,
              size: 30.sp,
            ),
            onPressed: () {},
          ),
          // 下一页
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_right,
              color: Colors.white,
              size: 30.sp,
            ),
            onPressed: () {},
          )
        ],
        mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
      ),
    ),
  );
}
