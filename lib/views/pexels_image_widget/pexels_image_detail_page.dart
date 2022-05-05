// ignore_for_file: avoid_print

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:freader/views/readhub_category/readhub_common_widgets.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 点击指定图片跳转的详情页
class PexelsImageDetailPage extends StatefulWidget {
  final PhotosData photoData;
  const PexelsImageDetailPage({Key? key, required this.photoData})
      : super(key: key);

  @override
  _PexelsImageDetailPageState createState() => _PexelsImageDetailPageState();
}

class _PexelsImageDetailPageState extends State<PexelsImageDetailPage> {
  @override
  void initState() {
    super.initState();

    // 获取存取权限
    _requestPermission();
  }

  // 是否在下载中（true显示一个滚动进度条，false则不显示）
  var downloading = false;

  @override
  Widget build(BuildContext context) {
    var pd = widget.photoData;
    var viewSrc = pd.src?.medium;
    // 下载使用原图途径和pexels的该图片id作为名称
    var downloadSrc = pd.src?.original;
    var photoName = "pexels_${pd.id}";

    return Scaffold(
      appBar: AppBar(
        title: const Text('照片详情'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1,
              child: SizedBox(
                width: double.infinity,
                child: viewSrc != ""
                    ? Image(
                        image: NetworkImage("$viewSrc"),
                      )
                    : const Icon(Icons.no_accounts),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0.sp),
            child: Text(
              "描述： ${pd.alt}",
              maxLines: 3,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.2,
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0.sp),
            child: Text(
              "作者：${pd.photographer}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0.sp),
            child: Text(
              "温馨提醒：下载默认为高清大图，注意流量消耗。",
              maxLines: 3,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.2,
              ),
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
                  size: 20.sp,
                ),
              ),
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "star",
                child: Icon(
                  Icons.star,
                  size: 20.sp,
                ),
              ),
              SmallButtonWidget(
                onTap: () => _downloadImage(downloadSrc!, photoName),
                tooltip: "download",
                child: Icon(
                  Icons.download,
                  color: Colors.lightBlue,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          // 照片下载进度条
          downloading
              ? LinearProgressIndicator(
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation(Colors.blue),
                )
              : Container(),
        ],
      ),
    );
  }

  // 下载图片到相册（默认Download文件夹）
  _downloadImage(String url, String name) async {
    _toastInfo("开始下载图片……");
    setState(() {
      downloading = true;
    });

    var appDocDir = await getTemporaryDirectory();
    String savePath = appDocDir.path;

    print("savePath $savePath");

    var response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );
    final result = await ImageGallerySaver.saveImage(
      Uint8List.fromList(response.data),
      quality: 100,
      name: name,
    );
    print(result);
    // _toastInfo("$result");
    _toastInfo("下载完成，请到相册查看");
    setState(() {
      downloading = false;
    });
  }

  // 查看和请求存储权限
  _requestPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.storage,
    ].request();

    final info = statuses[Permission.storage].toString();
    print(info);
    // _toastInfo(info);
  }

  // 透明小弹窗显示信息
  _toastInfo(String info) {
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
  }
}
