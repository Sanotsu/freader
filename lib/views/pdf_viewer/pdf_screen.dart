// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/utils/platform_util.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// 传入pdf所在的地址（文件名等），展示阅读器畫面
///
/// 2022-05-09
/// bug:syncfusion_flutter_pdfviewer 显示非英文的书签,是乱码
///
/// 不好搞的地方：记录阅读的進度和历史记录
///
class PDFScreen extends StatefulWidget {
  final String? path;
  final String? title;
  final File? file;

  const PDFScreen({Key? key, this.path, this.title, this.file})
      : super(key: key);

  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  // viewer控制器
  late PdfViewerController _pdfViewerController;
  // viewer的key
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  // viewer滚动显示方向
  late PdfScrollDirection scrollDirection;
  // viewer滚动显示方向对应的功能按钮图标
  var _directIcon = Icons.horizontal_distribute;

  @override
  void initState() {
    super.initState();
    print("path is ${widget.path},title is ${widget.title}");
    _pdfViewerController = PdfViewerController();
    scrollDirection = PdfScrollDirection.vertical;
  }

  // 切换滚动显示方向
  void _switchPdfScrollDirection() {
    setState(() {
      print(scrollDirection);
      if (scrollDirection == PdfScrollDirection.horizontal) {
        scrollDirection = PdfScrollDirection.vertical;
        _directIcon = Icons.horizontal_distribute;
      } else {
        scrollDirection = PdfScrollDirection.horizontal;
        _directIcon = Icons.vertical_distribute;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var filePath = widget.path ?? "";

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.title}'),
      ),
      // body: SfPdfViewer.network(
      //   'https://cdn.syncfusion.com/content/PDFViewer/flutter-succinctly.pdf',
      //   controller: _pdfViewerController, // pdfviewer的控制器
      //   key: _pdfViewerKey,
      //   scrollDirection: PdfScrollDirection.horizontal, // 切换滚动方向
      //   enableDoubleTapZooming: false, // 启动双击放大縮小
      // ),
      body: widget.file != null
          ? SfPdfViewer.file(
              widget.file!,
              controller: _pdfViewerController, // pdfviewer的控制器
              key: _pdfViewerKey, // 指定的pdfviewer对应的key
              scrollDirection: scrollDirection, // 切换滚动方向
              enableDoubleTapZooming: false, // 启动双击放大縮小
            )
          : SfPdfViewer.asset(
              filePath,
              controller: _pdfViewerController, // pdfviewer的控制器
              key: _pdfViewerKey, // 指定的pdfviewer对应的key
              scrollDirection: scrollDirection, // 切换滚动方向
              enableDoubleTapZooming: false, // 启动双击放大縮小
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.lightBlue,
      shape: const CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
      child: SizedBox(
        height: 30.sp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 书签
            IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Colors.white,
                size: 15.sp,
              ),
              onPressed: () {
                _pdfViewerKey.currentState?.openBookmarkView();
              },
            ),
            // 放大
            IconButton(
              icon: Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 15.sp,
              ),
              onPressed: () {
                _pdfViewerController.zoomLevel += 1;
              },
            ),
            // 縮小
            IconButton(
              icon: Icon(
                Icons.zoom_out,
                color: Colors.white,
                size: 15.sp,
              ),
              onPressed: () {
                _pdfViewerController.zoomLevel -= 1;
              },
            ),
            // 切换方向
            IconButton(
              icon: Icon(
                _directIcon,
                color: Colors.white,
                size: 15.sp,
              ),
              onPressed: _switchPdfScrollDirection,
            ),
            // 上一页
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 15.sp,
              ),
              onPressed: () {
                _pdfViewerController.previousPage();
              },
            ),
            // 下一页
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 15.sp,
              ),
              onPressed: () {
                _pdfViewerController.nextPage();
              },
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
        ),
      ),
    );
  }
}
