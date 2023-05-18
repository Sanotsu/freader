// ignore_for_file: avoid_print

import 'dart:io';
// import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:freader/widgets/common_widgets.dart';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 点击指定图片跳转的详情页
class PexelsImageDetailPage extends StatefulWidget {
  final PhotosData photoData;
  const PexelsImageDetailPage({Key? key, required this.photoData})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
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
    var downloadSrcList = [pd.src?.original, pd.src?.large2x, pd.src?.large];
    var photoName = "pexels_${pd.id}";
    // 文件后缀
    var fileSuffix = pd.src?.original?.split(".").last ?? "jpeg";

    print("传入的widget.photoData 后缀$fileSuffix--${widget.photoData.toJson()}");

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
              Expanded(
                flex: 2,
                child: Row(
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
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "原图",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SmallButtonWidget(
                      onTap: () => _downloadImage(
                        downloadSrcList[0] ?? "",
                        "${photoName}_origin.$fileSuffix",
                      ),
                      tooltip: "download",
                      child: Icon(
                        Icons.download,
                        color: Colors.lightBlue,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "高清",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SmallButtonWidget(
                      onTap: () => _downloadImage(
                        downloadSrcList[1] ?? "",
                        "${photoName}_large2x.$fileSuffix",
                      ),
                      tooltip: "download",
                      child: Icon(
                        Icons.download,
                        color: Colors.lightBlue,
                        size: 20.sp,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  children: [
                    Text(
                      "大图",
                      style: TextStyle(fontSize: 14.sp),
                    ),
                    SmallButtonWidget(
                      onTap: () => _downloadImage(
                        downloadSrcList[2] ?? "",
                        "${photoName}_large.$fileSuffix",
                      ),
                      tooltip: "download",
                      child: Icon(
                        Icons.download,
                        color: Colors.lightBlue,
                        size: 20.sp,
                      ),
                    ),
                  ],
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
    if (downloading) {
      _toastInfo("图片下载中，请先等待下载完成。");
      return;
    }

    _toastInfo("开始下载图片……");
    setState(() {
      downloading = true;
    });

    // 直接存入相册根目录，这样可以在自带的相册工具中查看
    // var savePath = await createFolderInDCIM();
    var savePath = GlobalConstants.androidPicturesPath;
    var filename = '$savePath/$name';

    // 获取网络图片数据
    var response = await Dio().get(
      url,
      options: Options(responseType: ResponseType.bytes),
    );

    // 存入文件系统
    final file = File(filename);
    await file.writeAsBytes(response.data);

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
    // Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_SHORT);
  }
}

// 注意，在安卓中，这在相册DCIM文件夹中的图片，在能在自带的相册应用中打开。
// 所以以下方案在DCIM中新增了文件夹，则无法直接在相册看到，需要找到指定文件夹才看得到。
Future<String> createFolderInDCIM() async {
// 这里是解决插件不能用的临时非方案，所以直接找到安卓下的DCIM地址(没有找到获取相册路径的工具库)，
// 创建项目名文件夹，然后用于保存下载的图片
  try {
    var temp = "${GlobalConstants.androidPicturesPath}freader/";
    final Directory appDocDirFolder = Directory(temp);
    if (await appDocDirFolder.exists()) {
      // 如果文件夹存在，返回地址
      return appDocDirFolder.path;
    } else {
      // 如果不存在，则创建该文件夹，然后返回
      final Directory appDocDirNewFolder =
          await appDocDirFolder.create(recursive: true);
      return appDocDirNewFolder.path;
    }
  } catch (e) {
    // 如果指定的DCIM位置出错，也给一个能存图片的地址，就应用内部的地址
    print("指定文件夹地址创建失败$e,"
        "返回临时地址。");
    var addDir = await getApplicationDocumentsDirectory();
    return addDir.path;
  }
}
