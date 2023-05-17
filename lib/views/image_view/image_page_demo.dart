import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 图片大模塊的占位（pexels级别）

class ImagePageDemo extends StatefulWidget {
  const ImagePageDemo({Key? key}) : super(key: key);

  @override
  State<ImagePageDemo> createState() => _ImagePageDemoState();
}

class _ImagePageDemoState extends State<ImagePageDemo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("ImagePageDemo"),
        // 2022-05-06 后续可参看 lib\_demos\search_on_app_bar.dart 做readhub的新闻查询。
        actions: <Widget>[
          IconButton(
            iconSize: 20.sp,
            icon: const Icon(
              Icons.search,
              color: Colors.black,
              semanticLabel: 'search', // icon的语义标签。
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: GridView.count(
        // 横轴子元素的数量。
        crossAxisCount: 2,
        padding: EdgeInsets.all(5.sp),
        // 子元素在横轴长度和主轴长度的比例。
        childAspectRatio: 8.0 / 6.0,
        children: _buildGridCards(10),
      ),
    );
  }

  List<Card> _buildGridCards(int count) {
// 创建List中用到的图片地址字串(List当前索引与10的余数)
    List imageUrlList = List.generate(
        count, (value) => "images/image_page_demo/demo${value % 5}.jpg");

    List<Card> cards = List.generate(
      count,
      (int index) => Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AspectRatio(
              aspectRatio: 16.0 / 9.0, // 宽高比
              child: Image.asset(imageUrlList[index]),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(5.sp, 4.sp, 5.sp, 2.3.sp),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "demo $index 标题",
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 6.sp,
                      height: 1.2,
                    ),
                  ),
                  SizedBox(height: 3.sp),
                  Text(
                    'demo $index 描述',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 6.sp,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );

    return cards;
  }
}
