// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';

import 'package:freader/views/pdf_viewer/pdf_screen.dart';

///
/// 2022-05-10 显示内置pdf文件列表
///
class EmbeddedPdfListWidget extends StatefulWidget {
  const EmbeddedPdfListWidget({Key? key}) : super(key: key);

  @override
  State<EmbeddedPdfListWidget> createState() => _EmbeddedPdfListWidgetState();
}

class _EmbeddedPdfListWidgetState extends State<EmbeddedPdfListWidget> {
  // app预计内置的pdf书籍
  final List<String> embeddedPdfList = [];

  @override
  void initState() {
    super.initState();
    // 初始化数据
    _retrieveEmbeddedPdfList();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(),
          SizedBox(
            height: 20.sp,
            child: Padding(
              padding: EdgeInsets.only(left: 10.sp),
              child: Text(
                "内置PDF文件",
                style: TextStyle(fontSize: 12.sp),
              ),
            ),
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                childAspectRatio: 4 / 2, // item的宽高比
                crossAxisCount: 3,
              ),
              itemCount: embeddedPdfList.length, // 文件的数量
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () => _onPdfCardTap(embeddedPdfList[index], context),
                  child: SizedBox(
                    height: 30.sp,
                    child: Card(
                      color: Colors.amber,
                      child: Center(
                        child: Text(
                          embeddedPdfList[index].split("/").last,
                          maxLines: 3,
                          style: TextStyle(fontSize: 8.sp),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// 获取pdf數量及位置数据等
  void _retrieveEmbeddedPdfList() async {
    // 获取assets文件夹下的文件
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // 过滤其下指定文件夹
    final embeddedPdfPathList = manifestMap.keys
        .where((String key) => key.contains('assets/pdfs'))
        .toList()
        .map((e) => Uri.decodeComponent(e))
        .toList();

    print(embeddedPdfPathList);

    setState(() {
      embeddedPdfList.addAll(embeddedPdfPathList);
    });
  }
}

/// 点击卡片，进行页面跳转
_onPdfCardTap(String filePath, BuildContext context) {
  print(filePath);
  String title = filePath.split("/").last;

  // 非特殊情況，跳转到指定页面
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext ctx) {
        return PDFScreen(
          path: filePath,
          title: title,
        );
      },
    ),
  );
}
