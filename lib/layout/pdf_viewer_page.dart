import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/pdf_viewer/pdf_screen.dart';
import 'package:freader/views/pdf_viewer/pick_local_pdf_file_widget.dart';

/// 显示書籍信息卡片，点击之后进入该書籍pdf阅读画面
///
class PdfViewerPage extends StatefulWidget {
  const PdfViewerPage({Key? key}) : super(key: key);

  @override
  State<PdfViewerPage> createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  final List<IconData> _icons = []; //保存Icon数据

  @override
  void initState() {
    super.initState();
    // 初始化数据
    _retrieveIcons();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SizedBox(
            height: 100.sp,
            child: const PickLocalPdfFile(),
          ),
        ),
        Expanded(
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
            ),
            itemCount: 10, // 文件的数量
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => _onPdfCardTap(context, index),
                child: Card(
                  color: Colors.amber,
                  child: Center(
                    child: Text('$index'),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
  }

  /// 模拟异步获取数据
  /// 获取pdf數量及位置数据等
  void _retrieveIcons() {
    Future.delayed(const Duration(milliseconds: 200)).then((e) {
      setState(() {
        _icons.addAll([
          Icons.ac_unit,
          Icons.airport_shuttle,
          Icons.all_inclusive,
          Icons.beach_access,
          Icons.cake,
          Icons.free_breakfast,
        ]);
      });
    });
  }
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
