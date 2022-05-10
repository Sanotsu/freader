// ignore_for_file: avoid_print

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:freader/views/pdf_viewer/pdf_screen.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() => runApp(const PickLocalPdfFile());

class PickLocalPdfFile extends StatefulWidget {
  const PickLocalPdfFile({Key? key}) : super(key: key);

  @override
  State<PickLocalPdfFile> createState() => _PickLocalPdfFileState();
}

class _PickLocalPdfFileState extends State<PickLocalPdfFile> {
  // 文件名
  String? _fileName;
  // 文件选取的结果
  // （目前是单文件打开，那就只有一个文件的List）
  List<PlatformFile>? _filePickerResultList;
  // 单选可这样
  // List<PlatformFile>? _filePickerResult;
  // 文件是否加载中
  bool _isLoading = false;
  // 用户是否中止文件选择
  bool _userAborted = false;

  @override
  void initState() {
    super.initState();
    _pickFiles();
  }

  /// 选择文件的操作
  void _pickFiles() async {
    _resetState();

    try {
      // 加载选择的文件
      _filePickerResultList = (await FilePicker.platform.pickFiles(
        // 文件的类型
        type: FileType.custom,
        // 允许选择的文件类型
        allowedExtensions: ['pdf'],
        // 文件加载中的操作
        onFileLoading: (FilePickerStatus status) => print(status),
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation' + e.toString());
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    // 加载成功之后，更新状态
    setState(() {
      _isLoading = false;
      _fileName = _filePickerResultList != null
          ? _filePickerResultList!.map((e) => e.name).toString()
          : '...';
      _userAborted = _filePickerResultList == null;
    });
  }

  /// 重置状态
  void _resetState() {
    if (!mounted) {
      return;
    }
    setState(() {
      _isLoading = true;
      _fileName = null;
      _filePickerResultList = null;
      _userAborted = false;
    });
  }

// final File myFile = File(platformFile.path);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Divider(),
        SizedBox(
          height: 20.sp,
          child: Padding(
            padding: EdgeInsets.only(left: 10.sp),
            child: Text(
              "自选PDF文件",
              style: TextStyle(fontSize: 12.sp),
            ),
          ),
        ),
        _isLoading
            ? const SizedBox(
                child: CircularProgressIndicator(),
              )
            : _userAborted
                ? const SizedBox(
                    child: Text(
                      '您已经中止了文件选择,关闭了弹窗.',
                    ),
                  )
                : _filePickerResultList != null
                    ? Expanded(
                        child: GridView.count(
                          childAspectRatio: 4 / 2, // item的宽高比
                          crossAxisCount: 3,
                          children: <Widget>[
                            GestureDetector(
                              onTap: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return PDFScreen(
                                        title: _fileName,
                                        file: File(
                                            _filePickerResultList![0].path ??
                                                ""),
                                      );
                                    },
                                  ),
                                )
                              },
                              child: SizedBox(
                                child: Card(
                                    color: Colors.amber,
                                    child: Center(
                                      child: Text(
                                        _fileName ?? '...',
                                        maxLines: 3,
                                        style: TextStyle(fontSize: 8.sp),
                                      ),
                                    )),
                              ),
                            )
                          ],
                        ),
                      )
                    : const SizedBox()
      ],
    );
  }
}
