// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/utils/sqlite_sql_statements.dart';
import 'package:freader/models/app_embedded/pdf_state.dart';
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
  final PdfState pdfState;

  const PDFScreen({Key? key, required this.pdfState}) : super(key: key);

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
    print(
        "path is ${widget.pdfState.filepath},title is ${widget.pdfState.filename}");
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pdfState.filename),
      ),
      // 如果是内嵌的要用asset，否则读文件
      /// 后续可以把内嵌的，放到app安装时默认生产的文件夹下去，然后再读，进行统一。此处仅用于学习接口
      body: widget.pdfState.source == PdfStateSource.embedded.toString()
          ? SfPdfViewer.asset(
              widget.pdfState.filepath,
              controller: _pdfViewerController, // pdfviewer的控制器
              key: _pdfViewerKey, // 指定的pdfviewer对应的key
              scrollDirection: scrollDirection, // 切换滚动方向
              enableDoubleTapZooming: false, // 启动双击放大縮小
              onDocumentLoadFailed: (detail) {
                print("asset pdf loadFailed: ${detail.error}");
                _showPdfLoadFailedDialog(context, detail.error);
              },
            )
          : SfPdfViewer.file(
              File(widget.pdfState.filepath),
              controller: _pdfViewerController, // pdfviewer的控制器
              key: _pdfViewerKey, // 指定的pdfviewer对应的key
              scrollDirection: scrollDirection, // 切换滚动方向
              enableDoubleTapZooming: false, // 启动双击放大縮小
              onDocumentLoadFailed: (detail) {
                print("file pdf loadFailed: ${detail.error}");
                _showPdfLoadFailedDialog(context, detail.error);
              },
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

  /// 如果是热门话题，则可以弹窗显示其新闻细节
  Future<void> _showPdfLoadFailedDialog(
      BuildContext context, String errMsg) async {
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          // 后续这些dialog等通用配置可以单独列，不要这样到处size都不同
          return AlertDialog(
            title: Text(
              'PDF加载失败',
              style: TextStyle(fontSize: 18.sp),
            ),
            content: Text(errMsg),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  '确定',
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ],
          );
        });
  }
}
