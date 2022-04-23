import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ImagePage extends StatelessWidget {
  const ImagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // 横轴子元素的数量。
      crossAxisCount: 2,
      padding: EdgeInsets.all(5.sp),
      // 子元素在横轴长度和主轴长度的比例。
      childAspectRatio: 8.0 / 6.0,
      children: _buildGridCards(10),
    );
  }

  List<Card> _buildGridCards(int count) {
// 创建List中用到的图片地址字串(List当前索引与10的余数)
    List imageUrlList = List.generate(
        count, (value) => "images/image_page_demo/demo${value % 10}.jpg");

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
