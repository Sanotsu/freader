// ignore_for_file: avoid_print

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/views/pdf_viewer/pdf_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

/// 2022-5-10 使用debug模式，app上开启权限之后，可以看到 /storage/emulated/0/Download 等文件夹的文件，
/// 使用run不一定有，但其实是打印字符串显示不全
///
void main() => runApp(const ScanLocalPdfListWidget());

class ScanLocalPdfListWidget extends StatefulWidget {
  const ScanLocalPdfListWidget({Key? key}) : super(key: key);

  @override
  State<ScanLocalPdfListWidget> createState() => _ScanLocalPdfListWidgetState();
}

class _ScanLocalPdfListWidgetState extends State<ScanLocalPdfListWidget> {
  // 要扫描的文件夹
  String rootDir = '/storage/emulated/0/';
  // 其中不扫描的文件夹
  String noPermissionDir = '/storage/emulated/0/Android';
  // 指定文件后缀
  String fileExtension = ".pdf";
  // 设备中指定后缀的所有文件
  List allDirExtensionFiles = [];

  @override
  void initState() {
    super.initState();
    _listOfFdfFiles();
  }

  // Make New Function
  void _listOfFdfFiles() async {
    //ask for permission
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      print(".....");
      await Permission.manageExternalStorage.request();
    }

    var status2 = await Permission.storage.status;
    if (!status2.isGranted) {
      await Permission.storage.request();
    }

    print("$status <---> $status2");

    print(status);

    // 获取所有第一级文件夹
    var dir = Directory(rootDir);
    var allFolderList = dir.listSync();

    // 临时获取所有文件夹的所有文件
    List<FileSystemEntity> tempList = [];
    // 因为 /storage/emulated/0/Android 没有权限掃描，所以其他的再递归掃描
    for (var folder in allFolderList) {
      if (folder.path != noPermissionDir) {
        tempList.addAll(Directory(folder.path).listSync(recursive: true));
      }
    }

    setState(() {
      // 筛选满足后缀条件的文件
      for (var element in tempList) {
        if (p.extension(element.path) == fileExtension) {
          allDirExtensionFiles.add(element);
        }
      }

      print(
          "=> allFileLength: ${tempList.length},pdfLength:${allDirExtensionFiles.length}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        SizedBox(
          height: 20.sp,
          child: Padding(
            padding: EdgeInsets.only(left: 10.sp),
            child: Text(
              "本地PDF文件",
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
            itemCount: allDirExtensionFiles.length,
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () =>
                    _onPdfCardTap(allDirExtensionFiles[index], context),
                child: SizedBox(
                  height: 30.sp,
                  child: Card(
                    color: Colors.amber,
                    child: Center(
                      child: Text(
                        "${allDirExtensionFiles[index].path.split("/").last}",
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
    );
  }
}

/// 点击卡片，进行页面跳转
_onPdfCardTap(File filePath, BuildContext context) {
  print(filePath);
  String title = filePath.path.split("/").last;

  // 非特殊情況，跳转到指定页面
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext ctx) {
        return PDFScreen(
          file: filePath,
          title: title,
        );
      },
    ),
  );
}
