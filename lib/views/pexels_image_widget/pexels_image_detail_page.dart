import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:freader/views/readhub_category/readhub_common_widgets.dart';

/// 点击指定图片跳转的详情页
class PexelsImageDetailPage extends StatelessWidget {
  final PhotosData photoData;
  const PexelsImageDetailPage({Key? key, required this.photoData})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var src = photoData.src?.medium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('照片详情 ✌️'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: double.infinity,
              child: src != ""
                  ? Image(
                      image: NetworkImage("$src"),
                    )
                  : const Icon(Icons.no_accounts),
            ),
          ),
          Text(
            "描述： ${photoData.alt}",
            maxLines: 3,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.2,
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0.sp),
            child: Text(
              "作者：${photoData.photographer}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          // 预留的照片详情的操作按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "share",
                child: Icon(
                  Icons.share,
                  size: 14.sp,
                ),
              ),
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "star",
                child: Icon(
                  Icons.star,
                  size: 14.sp,
                ),
              ),
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "download",
                child: Icon(
                  Icons.download,
                  size: 14.sp,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
