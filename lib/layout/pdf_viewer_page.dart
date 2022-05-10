// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/pdf_viewer/embedded_pdf_list_widget.dart';
import 'package:freader/views/pdf_viewer/pdf_screen.dart';
import 'package:freader/views/pdf_viewer/pick_local_pdf_file_widget.dart';
import 'package:freader/views/pdf_viewer/scan_local_pdf_list_widget.dart';

/// 显示書籍信息卡片，点击之后进入该書籍pdf阅读画面
///
class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({Key? key}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  // app预计内置的pdf书籍
  final List<String> embeddedPdfList = [];

// 是否显示设备中文件（通过此值判断是否点击了【全盤扫描】按钮）
  bool isShowDeviceFileList = false;

  // 是否显示打开文件夹选择的文件（通过此值判断是否点击了【打开本地文件】按钮）
  bool isShowPickFileList = false;

  @override
  void initState() {
    super.initState();
    // 初始化数据
    isShowDeviceFileList = false;
    isShowPickFileList = false;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 60.sp,
          child: Expanded(
            child: Row(
              children: [
                // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        isShowPickFileList = true;
                      })
                    },
                    child: Text(
                      '打开本地指定pdf',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: ElevatedButton(
                    onPressed: () => {
                      setState(() {
                        isShowDeviceFileList = true;
                      })
                    },
                    child: Text(
                      '全盘扫描本地pdf',
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Container(),
                ),
              ],
            ),
          ),
        ),
        isShowPickFileList
            ? const Expanded(
                child: PickLocalPdfFile(),
              )
            : Container(),
        const Divider(),
        isShowDeviceFileList
            ? const Expanded(
                child: ScanLocalPdfListWidget(),
              )
            : Container(),
        const EmbeddedPdfListWidget(),
      ],
    );
  }

  /// 模拟异步获取数据

}

/// 点击卡片，进行页面跳转
_onPdfCardTap(BuildContext context, int index) {
  String path, title = "";
  switch (index) {
    case 0:
      path = "assets/pdfs/5g应用场景300例.pdf";
      title = "5g应用场景300例";
      break;
    case 1:
      path = "assets/pdfs/corrupted.pdf";
      title = "corrupted";
      break;
    case 2:
      path = "assets/pdfs/demo-landscape.pdf";
      title = "demo-landscape";
      break;
    default:
      path = "assets/pdfs/隐形人格-思维和行为背后的人格奥秘_(澳)海伦·麦格拉斯_九州_2018.3.pdf";
      title = "隐形人格-思维和行为背后的人格奥秘_(澳)海伦·麦格拉斯_九州_2018.3";
  }

  // 非特殊情況，跳转到指定页面
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return PDFScreen(
          path: path,
          title: title,
        );
      },
    ),
  );
}
