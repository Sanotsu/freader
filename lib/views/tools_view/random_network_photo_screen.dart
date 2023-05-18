// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freader/common/personal/constants.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:photo_view/photo_view.dart';

class RandomNetworkPhotoScreen extends StatefulWidget {
  const RandomNetworkPhotoScreen({Key? key}) : super(key: key);

  @override
  State<RandomNetworkPhotoScreen> createState() =>
      _RandomNetworkPhotoScreenState();
}

class _RandomNetworkPhotoScreenState extends State<RandomNetworkPhotoScreen> {
// 2022-06-07 在https://www.hlapi.cn/中，还有效的随机图片地址
  var networkPhotoUrlList = [
    "https://www.hlapi.cn/api/ecy3", // 随机二次元图片③
    "https://www.hlapi.cn/api/gqbz", // 随机高清风景壁纸
    "https:/www.hlapi.cn/api/ecy1", // 随机二次元图片①
    "https://www.hlapi.cn/api/mcj", // 随机mc酱动漫图片
    "https://www.hlapi.cn/api/bjt", // 网站随机背景图
    "https://www.hlapi.cn/api/sjdm1", // 随机手机动漫图片①
    // "https://www.hlapi.cn/api/mm1", // 随机美女图片①
    // "https://www.hlapi.cn/api/mm2", // 随机美女图片②
    // "https://www.hlapi.cn/api/mjx", // 买家秀
    // "https://www.hlapi.cn/api/sjmm1", // 随机手机美女图片①
    // "https://www.hlapi.cn/api/gxdt", // 搞笑动态图片
  ];

// 用于显示的随机图片地址
  var rondomPhotoUrl = "";
  // 是否在下载中（true显示一个滚动进度条，false则不显示）
  var downloading = false;

  getRondomUrl() async {
    print("开始获取随机地址");
    final random = Random();
    int next(int min, int max) => min + random.nextInt(max - min);

    // 地址列表中随机一个地址
    var rondonInt = next(1, networkPhotoUrlList.length - 1);
    // 当前的时间戳作为随机数避免取缓存
    var timenumber = DateTime.now().millisecondsSinceEpoch;

    // 拼接随机图片地址并设定
    var url = "${networkPhotoUrlList[rondonInt]}?$timenumber";
    print("已经获取随机地址:$url");

    try {
      var response = await Dio().get(
        url,
        options: Options(responseType: ResponseType.bytes),
      );

      print("已经获取随机地址:$url 真实地址是${response.realUri}");

      setState(() {
        rondomPhotoUrl = response.realUri.toString();
      });
    } on DioError catch (e) {
      print("dio 错误信息");
      print(e.message);
      getRondomUrl();
    }
  }

  @override
  void initState() {
    getRondomUrl();
    // 获取存取权限
    _requestPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('随机网络图片'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 预留的照片详情的操作按鈕
          SizedBox(
            height: 100.sp,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: const [
                Text("左右滑动随机加载新图片"),
                Text("长按后松开保存当前图片"),
              ],
            ),
          ),

          Center(
            // 图片显示区域添加手势
            child: GestureDetector(
              // 左右滑动刷新图片（不是上一张下一张，都是随机新一张。）
              // 如果要实现向左滑新的一张，向右滑是上一张，的使用工具保存旧图片的真实地址
              onHorizontalDragEnd: (details) {
                print("onHorizontalDragEnd--- $details");
                getRondomUrl();
              },
              // 垂直滑动就保存图片到相册
              // onVerticalDragEnd: (details) {
              //   print("onVerticalDragEnd--- $details");
              //   _saveImage(rondomPhotoUrl);
              // },
              // 长按结束触发下载
              onLongPressEnd: (details) {
                print("onVerticalDragEnd--- $details");
                _downloadImage(rondomPhotoUrl);
              },
              // 设定子组件宽高比为1：1
              child: AspectRatio(
                aspectRatio: 1,
                child: Center(
                  // 使用此进行缩放
                  child: InteractiveViewer(
                    boundaryMargin: EdgeInsets.all(10.0.sp),
                    minScale: 0.1,
                    maxScale: 3.0,
                    // 这个可以缓存加载
                    child: CachedNetworkImage(
                      // 网络图片的地址
                      imageUrl: rondomPhotoUrl,
                      // 报错显示一个错误的图标
                      errorWidget: (context, url, error) =>
                          const Icon(Icons.error),
                      progressIndicatorBuilder:
                          (context, url, downloadProgress) => SizedBox(
                        width: 30.sp,
                        height: 30.sp,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: downloadProgress.progress,
                          ),
                        ),
                      ),
                      // 图片加载时的占位
                      // placeholder: (context, url) =>
                      //     const CircularProgressIndicator(
                      //   backgroundColor: Colors.red,
                      // ),
                    ),
                  ),

                  // 这个可以手势捏合缩放
                  // child: PhotoView(
                  //   imageProvider: NetworkImage(rondomPhotoUrl),
                  //   loadingBuilder: (context, event) {
                  //     print("event $event");

                  //     return Center(
                  //       child: SizedBox(
                  //         width: 20.0,
                  //         height: 20.0,
                  //         child: CircularProgressIndicator(
                  //           value: event == null
                  //               ? 0
                  //               : event.cumulativeBytesLoaded /
                  //                   event.expectedTotalBytes!,
                  //         ),
                  //       ),
                  //     );
                  //   },
                  // ),
                ),
              ),
            ),
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
  // 这里传入保存的，就需要是图片的真实地址
  _downloadImage(String url) async {
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
    var filename = "$savePath/${url.split("/").last}";

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
    print("获取存取权限--------------$info");
    _toastInfo(info);
  }

  // 透明小弹窗显示信息
  _toastInfo(String info) {
    // Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_LONG);
    Fluttertoast.showToast(msg: info, toastLength: Toast.LENGTH_SHORT);
  }
}
