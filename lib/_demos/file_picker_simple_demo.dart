// ignore_for_file: avoid_print

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PickLocalPdfFile());

class PickLocalPdfFile extends StatefulWidget {
  const PickLocalPdfFile({Key? key}) : super(key: key);

  @override
  State<PickLocalPdfFile> createState() => _PickLocalPdfFileState();
}

class _PickLocalPdfFileState extends State<PickLocalPdfFile> {
  // Scaffold组件 的key
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  // Scaffold组件消息 的key
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

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

  /// 选择文件的操作
  void _pickFiles() async {
    _resetState();

    try {
      // 加载选择的文件
      _filePickerResultList = (await FilePicker.platform.pickFiles(
        // 文件的类型
        type: FileType.custom,
        // 允许选择的文件类型
        allowedExtensions: ['pdf', "txt", "jpg"],
        // 文件加载中的操作
        onFileLoading: (FilePickerStatus status) => print(status),
      ))
          ?.files;
    } on PlatformException catch (e) {
      _logException('Unsupported operation' + e.toString());
    } catch (e) {
      _logException(e.toString());
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

  /// 打印异常信息
  void _logException(String message) {
    print(message);
    _scaffoldMessengerKey.currentState?.hideCurrentSnackBar();
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scaffoldMessengerKey: _scaffoldMessengerKey,
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: const Text('File Picker example app'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, right: 10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.only(top: 50.0, bottom: 20.0),
                    child: Column(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () => _pickFiles(),
                          child: const Text('Pick file'),
                        ),
                      ],
                    ),
                  ),
                  Builder(
                    builder: (BuildContext context) => _isLoading
                        ? const Padding(
                            padding: EdgeInsets.only(bottom: 10.0),
                            child: CircularProgressIndicator(),
                          )
                        : _userAborted
                            ? const Padding(
                                padding: EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'User has aborted the dialog',
                                ),
                              )
                            : _filePickerResultList != null
                                ? ListTile(
                                    title: Text(
                                      _fileName ?? '...',
                                    ),
                                    subtitle: Text(
                                        _filePickerResultList![0].path ?? ""),
                                  )
                                : const SizedBox(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
