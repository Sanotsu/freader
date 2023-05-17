// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/utils/sqlite_helper.dart';
import 'package:freader/common/utils/sqlite_sql_statements.dart';
import 'package:freader/models/app_embedded/pdf_state.dart';
import 'package:freader/utils/platform_util.dart';
import 'package:intl/intl.dart';
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
  // ignore: library_private_types_in_public_api
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

  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    print(
        "path is ${widget.pdfState.filepath},title is ${widget.pdfState.filename}");

    _pdfViewerController = PdfViewerController();
    scrollDirection = PdfScrollDirection.vertical;
  }

// 等待pdf文件加载完之后，再跳转到已读进度的页面
  initReadProgress() {
    print("pdf加载完后的数据");
    print(_pdfViewerController.pageCount);
    print(_pdfViewerController.pageNumber);
    print(widget.pdfState.readProgress);

    // 2022-05-14 初始时跳转到指定已读位置(readProgress 是0-100表示進度，所以這里要先除以100)
    // 如果是0，那从1开始，否则就是原始比例值
    var tempReadPage = ((_pdfViewerController.pageCount) *
            (widget.pdfState.readProgress / 100))
        .round();
    var readPage = tempReadPage == 0 ? 1 : tempReadPage;

    _pdfViewerController.jumpToPage(readPage.round());
  }

// 保存阅读进度，在返回前要更新
  saveReadProgress() async {
    // 2022-05-14 推出前记录已读的数据

    // 进度0-100表示0-100%
    var tempReadProgress = double.parse(
            (_pdfViewerController.pageNumber / _pdfViewerController.pageCount)
                .toStringAsFixed(4)) *
        100;

    var tempPdfState = PdfState(
      id: widget.pdfState.id,
      filename: widget.pdfState.filename,
      filepath: widget.pdfState.filepath,
      source: widget.pdfState.source,
      readProgress: tempReadProgress,
      // 简单转换显示时间，不一定对，但逻辑肯定不全，只是为了省事
      lastReadDatetime: DateFormat('yyyy-MM-dd HH:mm:ss').format(
          (DateTime.now().toLocal()).isUtc
              ? DateTime.now()
              : DateTime.now().add(const Duration(hours: 8))),
    );

    await _databaseHelper.updatePdfState(tempPdfState);

    print("离开时的数据");
    print(_pdfViewerController.pageCount);
    print(_pdfViewerController.pageNumber);
    print(tempReadProgress);
  }

  // 切换滚动显示方向
  void _switchPdfScrollDirection() {
    setState(() {
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
        // leading的返回按钮，是点击上方默认的路由返回按钮会触发，也能传值。优先级高于willPopScope
        // leading: BackButton(
        //   onPressed: () => Navigator.pop(context, "child route data"),
        // ),
      ),
      // 202-05-16 WillPopScope 在点击默认返回的简单图标或者下方的返回按钮，都能触发，并传递值到上一个router
      // 如果没有上面的 AppBar -> leading 的返回，则上方默认返回箭头或者返回键都会触发此。
      body: WillPopScope(
        onWillPop: () async {
          // 点击appbar返回按钮或者返回键时，先保持已读的进度
          await saveReadProgress();
          if (mounted) {
            Navigator.pop(context);
            // Navigator.pop(context, "data you want return");
          }
          return false;
        },
        // 如果是内嵌的要用asset，否则读文件
        /// 后续可以把内嵌的，放到app安装时默认生产的文件夹下去，然后再读，进行统一。此处仅用于学习接口
        child: widget.pdfState.source == PdfStateSource.embedded.toString()
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
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    initReadProgress();
                  });
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
                onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                  setState(() {
                    initReadProgress();
                  });
                },
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return BottomAppBar(
      color: Colors.lightBlue,
      shape: const CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
      child: SizedBox(
        height: 40.sp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 书签
            IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Colors.white,
                size: 25.sp,
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
                size: 25.sp,
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
                size: 25.sp,
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
                size: 25.sp,
              ),
              onPressed: _switchPdfScrollDirection,
            ),
            // 上一页
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 25.sp,
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
                size: 25.sp,
              ),
              onPressed: () {
                _pdfViewerController.nextPage();
              },
            )
          ], //均分底部导航栏横向空间
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
