// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:convert';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/utils/sqlite_helper.dart';
import 'package:freader/common/utils/sqlite_sql_statements.dart';
import 'package:freader/models/app_embedded/pdf_state.dart';
import 'package:freader/views/pdf_view/pdf_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

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

// ---------------------
  // 要扫描的文件夹(在实机上扫不出来)
  String rootDir = '/storage/emulated/0';
  // 其中不扫描的文件夹
  String noPermissionDir = '/storage/emulated/0/Android';
  // 指定文件后缀
  String fileExtension = ".pdf";

  // 扫描到的文件（可用于展示扫描的数量）
  List scanPdfList = [];

  // 是否扫描中
  bool sacnLoading = false;
  // 当前扫描文件夹和文件
  var currentDir = "";
  var currentFile = "";

// ---------------------
  // 文件选取的结果
  List<File> pickedFileList = [];
// ---------------------

  // 设备中指定后缀的所有文件(san、pick、embed之和)
  List<PdfState> allDirExtensionFiles = [];
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _getAllPdfs();
  }

  /// 获取数据库中已有的文件
  void _getAllPdfs() async {
    _retrieveEmbeddedPdfList();
    var tempPdfStateList = await _databaseHelper.readPdfStateList();
    setState(() {
      allDirExtensionFiles = tempPdfStateList;
    });
  }

// 这里其实是出现了sqlite 数据丟失或者db损坏等问题，导致无法显示或者扫描pdf list
// 那就只能重新加载数据了，删除db，一切归零
  _emergencyHandle() {
    _databaseHelper.deleteDb();
    _getAllPdfs();
  }

  /// 1 获取设备本地已有的pdf文件
  void _scanAllLocalPdfs() async {
    setState(() {
      sacnLoading = true;
      currentDir = "";
      currentFile = "";
    });

    // 获取存储权限
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    // 获取所有第一级文件夹(allRootFileSystemEntityList)
    var allRootFSEList = Directory(rootDir).listSync();
    // 存放pdf信息的数据列表
    List<PdfState> pdfStateList = [];

    // 临时获取所有文件夹的所有文件
    List<FileSystemEntity> tempList = [];
    // 因为 /storage/emulated/0/Android 没有权限掃描，所以其他的再递归掃描
    for (var fse in allRootFSEList) {
      // 为了方便看清楚，才延迟显示1秒
      // await Future.delayed(const Duration(seconds: 1));

      // 如果是根文件夹下的文件，则直接加入list
      if (fse.runtimeType.toString() == "_File") {
        tempList.add(fse);
      }

      // 如果是文件夹，且不为没权限扫描的文件夹,则递归便利其文件夹，把文件加入list，不是文件则忽略
      if (fse.runtimeType.toString() == "_Directory" &&
          fse.path != noPermissionDir) {
        await Directory(fse.path).list(recursive: true).forEach((f) {
          setState(() {
            currentDir = fse.path;
            currentFile = f.path;
          });

          if (f.runtimeType.toString() == "_File") {
            tempList.add(f);
          }
        });
      }
      // 其他的例如link，就不管了
    }

    // 重新扫描时，先清空
    scanPdfList = [];

    // 筛选满足后缀条件的文件
    for (var file in tempList) {
      if (p.extension(file.path).toLowerCase() == fileExtension) {
        // 构建数据实例
        var pdfState = PdfState(
          filename: file.path.split("/").last,
          filepath: file.path,
          source: PdfStateSource.scanned.toString(),
          readProgress: 0, // 新扫描到進度都为0
          lastReadDatetime: "-",
        );
        pdfStateList.add(pdfState);

        scanPdfList.add(file);
      }
    }

    // 添加到数据库(如果数据库中已有同名、且同位置的，则不新增/// 其实应该不会存在这样的文件了)
    for (var pdfFile in pdfStateList) {
      var alreadyList =
          await _databaseHelper.queryPdfStateByFilename(pdfFile.filename);

      var alreadyFlag = false;
      for (var ele in alreadyList) {
        if (pdfFile.filepath == ele.filepath) {
          alreadyFlag = true;
          break;
        }
      }

      if (!alreadyFlag) {
        await _databaseHelper.insertPdfState(pdfFile);
      }
    }

    // 改变其值状态
    var tempPdfStateList = await _databaseHelper.readPdfStateList();
    setState(() {
      allDirExtensionFiles = tempPdfStateList;
      sacnLoading = false;
    });
  }

  /// 2 选择文件的操作
  /// 2022-05-12 因为无法获取到文件的真实路径（https://github.com/miguelpruivo/flutter_file_picker/wiki/FAQ 第一个），
  /// pdf-viewer其实无法打开缓存的文件(勘误：其实可以打开缓存文件，但同样存在同一份路劲的文件，因为扫描和自选变成两个路径的文件)。
  /// 所以此处是点选了文件加载到缓存后，默认副本到指定文件夹下，打开时，使用新的位置。
  void _pickAndSaveOnePdf() async {
    /// 1 清除已经选择的文件
    setState(() {
      pickedFileList = [];
    });

    /// 2 获取自选的文件
    // file picker选取放到缓存中的文件
    List<PlatformFile>? filePickerResultList;
    try {
      // 加载选择的文件
      filePickerResultList = (await FilePicker.platform.pickFiles(
        // 文件的类型
        type: FileType.custom,
        // 允许选择的文件类型
        allowedExtensions: ['pdf'],
        // 文件加载中的操作
        onFileLoading: (FilePickerStatus status) => print(status),
      ))
          ?.files;
    } on PlatformException catch (e) {
      print('Unsupported operation$e');
    } catch (e) {
      print(e.toString());
    }

    /// 3 将选择的文件移到应用内，以便pdf-viewer可以打开

    /// 2022-05-12 ,像这种获取权限，ios和安卓不一样，应该抽出來作为公共的方法
    var statese = await [
      Permission.accessMediaLocation,
      Permission.storage,
      Permission.manageExternalStorage
    ].request();

    print(statese);
    // 2022-05-12 要复制到的文件夹路径（getApplicationDocumentsDirectory create会报错）
    // getApplicationSupportDirectory() 获取到的是 /data/user/0/com.example.freader...路径，只有root权限才能用
    // 所以把文件复制到这里面，也是无法打开的。
    var appSupDir = (await getExternalStorageDirectory())!.path;

    // 目标文件夹，不存在要创建
    var appSupPdfDir = "$appSupDir/pdfs";
    if (!(await Directory(appSupPdfDir).exists())) {
      await Directory(appSupPdfDir).create(recursive: true);
    }

    // 如果有选择的文件，则複製到应用指定路径
    if (filePickerResultList != null) {
      for (var pfFile in filePickerResultList) {
        // 因为pef viewer可以打开缓存文件，所以不用移动到指定文件夹了
        // var tempNewFile =
        //     await copyFile(File(pfFile.path!), "$appSupPdfDir/${pfFile.name}");

        var tempNewFile = File(pfFile.path!);

        pickedFileList.add(tempNewFile);
      }
    }

    // // 查看文件是否過去了
    // var temp = Directory(appSupPdfDir).listSync();

    // print('---------------');
    // print(temp);
    // print(_filePickerResultList);

    /// 如果有选取到文件，则加到数据库(一个值的list也当作选择了多个)
    for (var f in pickedFileList) {
      var fname = f.path.split("/").last;
      var alreadyList = await _databaseHelper.queryPdfStateByFilename(fname);
      var alreadyFlag = false;

      for (var ele in alreadyList) {
        if (f.path == ele.filepath) {
          alreadyFlag = true;
          break;
        }
      }

      if (!alreadyFlag) {
        var tempPdfState = PdfState(
          filename: fname,
          filepath: f.path,
          source: PdfStateSource.picked.toString(),
          readProgress: 0.0,
          lastReadDatetime: "-",
        );
        await _databaseHelper.insertPdfState(tempPdfState);
      }
    }

    // 改变其值状态
    var tempPdfStateList = await _databaseHelper.readPdfStateList();
    setState(() {
      allDirExtensionFiles = tempPdfStateList;
    });
  }

  /// 移动指定文件到新的路径
  Future<File> copyFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      print("复制文件新旧地址不在同一路径：${e.message},rename()无效,将使用copy()方法.");
      // if rename fails, copy the source file
      final newFile = await sourceFile.copy(newPath);
      return newFile;
    }
  }

  /// 3 获取pdf數量及位置数据等
  void _retrieveEmbeddedPdfList() async {
    // 获取assets文件夹下的文件
    final manifestContent = await rootBundle.loadString('AssetManifest.json');
    final Map<String, dynamic> manifestMap = json.decode(manifestContent);
    // 过滤其下指定文件夹
    final embeddedPdfPathList = manifestMap.keys
        .where((String key) => key.contains('assets/pdfs'))
        // .toList()
        // .map((e) => Uri.decodeComponent(e)) // 2023-03-31新版本转码后会报错，不能识别
        .toList();

    setState(() {
      embeddedPdfList.addAll(embeddedPdfPathList);
    });

    // 添加到数据库(如果数据库中已有同名、且同位置的，则不新增/// 其实应该不会存在这样的文件了)
    for (var filePath in embeddedPdfList) {
      var alreadyList = await _databaseHelper
          .queryPdfStateByFilename(filePath.split("/").last);

      var alreadyFlag = false;
      for (var ele in alreadyList) {
        if (filePath == ele.filepath) {
          alreadyFlag = true;
          break;
        }
      }

      if (!alreadyFlag) {
        var tempPdfState = PdfState(
          filename: filePath.split("/").last,
          filepath: filePath,
          source: PdfStateSource.embedded.toString(),
          readProgress: 0.0,
          lastReadDatetime: "-",
        );
        await _databaseHelper.insertPdfState(tempPdfState);
      }
    }

    // 改变其值状态
    var tempPdfStateList = await _databaseHelper.readPdfStateList();
    setState(() {
      allDirExtensionFiles = tempPdfStateList;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 4,
              child: ElevatedButton(
                onPressed: () => _pickAndSaveOnePdf(),
                child: Text(
                  '自选单个pdf  ${pickedFileList.length}',
                  style: TextStyle(fontSize: 10.sp),
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
                onPressed: () => _scanAllLocalPdfs(),
                child: Text(
                  '扫描全盘pdf  ${scanPdfList.length}',
                  style: TextStyle(fontSize: 10.sp),
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
            Expanded(
              flex: 1,
              child: IconButton(
                onPressed: () => _emergencyHandle(),
                iconSize: 16.sp,
                icon: const Icon(Icons.emergency),
                color: Colors.red,
              ),
            ),
            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
        // widget居中
        Center(
          child: Text(
            '''
pdf viwer使用的是 syncfusion_flutter_pdfviewer 库,内置功能很多,但加载很慢,bug很多,比较卡顿.
不要轻易点击emergency 图标,除非出现已有的pdf列表突然变为空,全盘扫描失效.
如果还是不行,则只能清空用户数据或者重装app.两者皆会丟失阅读记录.
          ''',
            textAlign: TextAlign.center, // 文本内容居中
            style: TextStyle(fontSize: 8.sp),
          ),
        ),
        sacnLoading
            ? LinearProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                semanticsValue: "sdsdsd")
            : Container(),
        sacnLoading
            ? Text(
                currentDir,
                style: TextStyle(fontSize: 12.sp),
              )
            : Container(),
        sacnLoading
            ? Text(
                currentFile,
                style: TextStyle(fontSize: 12.sp),
              )
            : Container(),
        _buildPdfGriwView(allDirExtensionFiles, _getAllPdfs),
      ],
    );
  }

  /// 模拟异步获取数据
}

/// 点击卡片，进行页面跳转
_onPdfCardTap(
    PdfState pdfState, BuildContext context, Function refreshData) async {
  // 非特殊情況，跳转到指定页面
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext ctx) {
        return PDFScreen(
          pdfState: pdfState,
        );
      },
    ),
  ).then((value) {
    print("这是跳转路由后返回的数据： $value");
    // 在pdf viewer页面返回后，重新获取pdf list，更新阅读进度
    refreshData();
  });
}

// 构建pdf griw列表
_buildPdfGriwView(List<PdfState> pdfStateList, Function getAllPdfs) {
  var mainTextSize = TextStyle(fontSize: 7.sp);
  return Expanded(
    child: GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 16 / 9, // item的宽高比
        crossAxisCount: 2,
      ),
      itemCount: pdfStateList.length, // 文件的数量
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          onTap: () => _onPdfCardTap(pdfStateList[index], context, getAllPdfs),
          child: SizedBox(
            child: Card(
              color: Colors.lightGreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
                      Expanded(
                        flex: 1,
                        child: Text("文件名称", style: mainTextSize),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          pdfStateList[index].filename,
                          maxLines: 3,
                          style: TextStyle(fontSize: 10.sp),
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 5.sp),
                  Row(
                    children: [
                      // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
                      Expanded(
                        flex: 1,
                        child: Text("文件路径", style: mainTextSize),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          pdfStateList[index].filepath,
                          maxLines: 3,
                          style: mainTextSize,
                        ),
                      ),
                    ],
                  ),
                  Divider(height: 5.sp),
                  Row(
                    children: [
                      // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
                      Expanded(
                        flex: 1,
                        child: Text("文件来源", style: mainTextSize),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          pdfStateList[index].source,
                          style: mainTextSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
                      Expanded(
                        flex: 1,
                        child: Text("阅读进度", style: mainTextSize),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          "${pdfStateList[index].readProgress}%",
                          style: mainTextSize,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      // 2022-05-10 注意，这里都只是按鈕点击了一次之后就无法使用了，因为setState都固定
                      Expanded(
                        flex: 1,
                        child: Text("上次阅读", style: mainTextSize),
                      ),
                      Expanded(
                        flex: 4,
                        child: Text(
                          pdfStateList[index].lastReadDatetime,
                          style: mainTextSize,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

/// 构建pdf list view
///
/// 长按card或者row弹窗点击移除，则从sqlite中移除该数据
