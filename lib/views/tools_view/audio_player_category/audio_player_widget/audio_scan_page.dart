// ignore_for_file: avoid_print

import 'dart:io';

import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/common/utils/sqlite_audio_helper.dart';
import 'package:freader/models/app_embedded/local_audio_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:path/path.dart' as path;

class AudioScanPage extends StatefulWidget {
  const AudioScanPage({Key? key}) : super(key: key);

  @override
  State<AudioScanPage> createState() => _AudioScanPageState();
}

class _AudioScanPageState extends State<AudioScanPage> {
// 随机编号生成工具类
  var uuid = const Uuid();
  // db工具类
  final AudioDbHelper audioDbHelper = AudioDbHelper();

  // 要扫描的文件夹(在实机上扫不出来)
  String rootDir = '/storage/emulated/0/Music/test';
  // String rootDir = '/storage/emulated/0';
  // String rootDir = "/storage/emulated/0/netease/cloudmusic/Cache/LTBeep";
  // 其中不扫描的文件夹
  List<String> noPermissionDirList = [
    '/storage/emulated/0/Android',
    '/storage/emulated/0/MIUI',
  ];
  // 指定文件后缀
  List<String> fileExtensionList = [".mp3", ".wma", ".wav", ".ape", ".flac"];
  // 扫描到可以存放到db的歌曲文件信息的列表
  List<LocalAudioInfo> dbAudioInfoList = [];
  // 扫描到的音频文件列表
  List scannedAudioList = [];

// 是否扫描中
  bool sacnLoading = false;
  // 当前扫描文件夹和文件
  var currentDir = "";
  var currentFile = "";

// ===============
  int selectedIndex = -1;

// 被选中的音频列表
  List selectedAudioList = [];

  // 所有的歌单信息（供下拉选择只能是string列表）
  List<String> allPlaylist = [];
  // 数据库中存在的所有歌单（）包含完整信息
  List<LocalAudioPlaylist> allDbPlaylist = [];
  // 被选中要加入的歌单名称
  //      初始化时，被选中的歌单是我的最爱
  String selectedPlaylistName = GlobalConstants.localAudioMyFavoriteName;

  // 是否正在执行加入歌单操作
  bool isAddingToPlaylist = false;

  late Color color;

  @override
  void initState() {
    super.initState();
    getAllPlaylist();
  }

  // === 查看歌单列表
  getAllPlaylist() async {
    var tempList = await audioDbHelper.getLocalAudioPlaylist(isFull: false);

    setState(() {
      allDbPlaylist = [];
      allDbPlaylist = tempList;

      allPlaylist = [];
      for (var e in tempList) {
        allPlaylist.add(e.audioPlaylistName);
      }
    });
  }

  /// 扫描全盘文件夹，找符合后缀的文件
  /// (修改当前扫描的文件夹和文件名的状态在这里面改)
  void _scanAllLocalAudio() async {
    setState(() {
      sacnLoading = true;
      currentDir = "";
      currentFile = "";
    });

    //1 获取存储权限
    var status = await Permission.manageExternalStorage.status;
    if (status.isDenied) {
      await Permission.manageExternalStorage.request();
    }
    var storageStatus = await Permission.storage.status;
    if (!storageStatus.isGranted) {
      await Permission.storage.request();
    }

    /// 2 获取可扫描的文件夹
    // 获取所有第一级文件夹(allRootFileSystemEntityList)
    var allRootFSEList = Directory(rootDir).listSync();

    // 重新扫描时，先清空
    dbAudioInfoList = [];
    scannedAudioList = [];

    // 因为 /storage/emulated/0/Android 没有权限掃描，所以其他的再递归掃描
    for (var fse in allRootFSEList) {
      // 为了方便看清楚，才延迟显示1秒
      await Future.delayed(const Duration(microseconds: 100));

      // 如果是根文件夹下的文件，则直接加入list
      if (fse.runtimeType.toString() == "_File") {
        // 显示当前扫描的文件夹和文件
        setState(() {
          currentDir = fse.path;
        });

        await _saveAudioFileInfoToDB(fse);
      }

      // 如果是文件夹，且不为没权限扫描的文件夹,则递归便利其文件夹，把文件加入list，不是文件则忽略
      if (fse.runtimeType.toString() == "_Directory" &&
          !noPermissionDirList.contains(fse.path)) {
        await Directory(fse.path).list(recursive: true).forEach((f) async {
          // 显示当前扫描的文件夹和文件
          setState(() {
            currentFile = f.path;
          });

          if (f.runtimeType.toString() == "_File") {
            await _saveAudioFileInfoToDB(f);
          }
        });
      }
      // 其他的例如link，就不管了
    }

    setState(() {
      sacnLoading = false;
    });
  }

  /// 将扫描到的指定文件进行音频判断，拼按照是否已经存放到db后进行相关操作
  /// (关于扫描到的音频文件数量和db去重后新增的数量的状态在这里改)
  _saveAudioFileInfoToDB(FileSystemEntity f) async {
    // 1 查看文件是否属于音频后缀，如果是，构建db音频信息row
    if (fileExtensionList.contains(path.extension(f.path).toLowerCase())) {
      // 只要扫描到音频文件就记录，不管有没有加入过db
      setState(() {
        scannedAudioList.add(f);
      });

      var audioName = f.path.split("/").last;

      // 查询该音频文件是否已经存在于数据库
      var alreadyList =
          await audioDbHelper.queryLocalAudioInfo(audioName: audioName);

      // 文件名和路径是一样的，就表示已经存过了
      var alreadyFlag = false;
      for (var ele in alreadyList) {
        if (f.path == ele.audioPath) {
          alreadyFlag = true;
          break;
        }
      }

      // 如果该音频文件未加入数据库音频信息基础表，则添加进去
      if (!alreadyFlag) {
        // 构建数据实例
        var audioInfo = LocalAudioInfo(
          audioName: audioName,
          audioPath: f.path,
          audioId: uuid.v1(),
        );
        await audioDbHelper.insertLocalAudioInfo(audioInfo);

        // 也存到默认全局歌单去
        var audioPlayListInfo = LocalAudioPlaylist(
          audioId: audioInfo.audioId,
          audioPlaylistId: GlobalConstants.localAudioDeaultPlaylistId,
          audioPlaylistName: GlobalConstants.localAudioDeaultPlaylistName,
          audioName: audioInfo.audioName,
          audioPath: audioInfo.audioPath,
        );

        await audioDbHelper.insertLocalAudioPlaylist(audioPlayListInfo);

        // 插入db后，也更新前端显示存入db的音频信息数量列表的状态
        setState(() {
          dbAudioInfoList.add(audioInfo);
        });
      }
    }
  }

  /// 把选择的音频加到被选中的歌单去
  addSelectedAudioListToSelectedPlaylist() async {
    setState(() {
      isAddingToPlaylist = true;
    });
    print("hhhhhhhhhhhhhhhh");

    print(selectedAudioList.length);
    print(selectedPlaylistName);

    // 取得其要添加的歌单的id信息
    var selectPlaylist = allDbPlaylist
        .where((row) => (row.audioPlaylistName == selectedPlaylistName));

    print("----$selectPlaylist");

    // 遍历把歌加入歌单
    //      如果该歌曲还没有到歌曲基础表，也得加进去
    for (var element in selectedAudioList) {
      var fileName = element.path.split("/").last;
      //点击确定之后，
      //如果已存在，则不新增。否则，新增
      var alreadyList = await audioDbHelper.checkIsAudioInPlaylistByName(
        selectedPlaylistName,
        fileName,
      );

      // 是否存在与歌曲基础表
      var audioInfoAlreadyList =
          await audioDbHelper.queryLocalAudioInfo(audioName: fileName);

      var alreadyFlag = false;
      for (var ele in audioInfoAlreadyList) {
        if (element.path == ele.audioPath) {
          alreadyFlag = true;
          break;
        }
      }

      var uid = uuid.v1();

      if (!alreadyFlag) {
        await audioDbHelper.insertLocalAudioInfo(LocalAudioInfo(
          audioName: fileName,
          audioPath: element.path,
          audioId: uid,
        ));
      }

      //如果不存在，把当前音频添加到选中的歌单去（新增db row）
      if (alreadyList <= 0) {
        var lap = LocalAudioPlaylist(
            audioPlaylistId: selectPlaylist.first.audioPlaylistId,
            audioPlaylistName: selectedPlaylistName,
            audioId: uid,
            audioName: element.path.split("/").last,
            audioPath: element.path);

        await audioDbHelper.insertLocalAudioPlaylist(lap);
      }
    }

    setState(() {
      isAddingToPlaylist = false;
    });
  }

  // void _scanAllLocalAudio() async {
  //   setState(() {
  //     sacnLoading = true;
  //     currentDir = "";
  //     currentFile = "";
  //   });
  //
  //   //1 获取存储权限
  //   var status = await Permission.manageExternalStorage.status;
  //   if (status.isDenied) {
  //     await Permission.manageExternalStorage.request();
  //   }
  //   var storageStatus = await Permission.storage.status;
  //   if (!storageStatus.isGranted) {
  //     await Permission.storage.request();
  //   }
  //
  //   /// 2 获取可扫描的文件夹
  //   // 获取所有第一级文件夹(allRootFileSystemEntityList)
  //   var allRootFSEList = Directory(rootDir).listSync();
  //
  //   // 临时获取所有文件夹的所有文件
  //   List<FileSystemEntity> tempList = [];
  //
  //   // 因为 /storage/emulated/0/Android 没有权限掃描，所以其他的再递归掃描
  //   for (var fse in allRootFSEList) {
  //     // 为了方便看清楚，才延迟显示1秒
  //     await Future.delayed(const Duration(microseconds: 100));
  //
  //     // 如果是根文件夹下的文件，则直接加入list
  //     if (fse.runtimeType.toString() == "_File") {
  //       tempList.add(fse);
  //     }
  //
  //     // 如果是文件夹，且不为没权限扫描的文件夹,则递归便利其文件夹，把文件加入list，不是文件则忽略
  //     if (fse.runtimeType.toString() == "_Directory" &&
  //         !noPermissionDirList.contains(fse.path)) {
  //       await Directory(fse.path).list(recursive: true).forEach((f) {
  //         // 显示当前扫描的文件夹和文件
  //         setState(() {
  //           currentDir = fse.path;
  //           currentFile = f.path;
  //         });
  //
  //         if (f.runtimeType.toString() == "_File") {
  //           tempList.add(f);
  //
  //           if (fileExtensionList
  //               .contains(path.extension(f.path).toLowerCase())) {
  //             // 构建数据实例
  //             var audioInfo = LocalAudioInfo(
  //               audioName: f.path.split("/").last,
  //               audioPath: f.path,
  //               audioId: uuid.v1(),
  //             );
  //             audioList.add(audioInfo);
  //           }
  //         }
  //       });
  //     }
  //     // 其他的例如link，就不管了
  //   }
  //
  //   // 重新扫描时，先清空
  //   audioList = [];
  //   scannedAudioList = [];
//
  //   // 3 筛选满足后缀条件的文件构建音乐信息实例
  //   for (var file in tempList) {
  //     if (fileExtensionList.contains(path.extension(file.path).toLowerCase())) {
  //       // 构建数据实例
  //       var audioInfo = LocalAudioInfo(
  //         audioName: file.path.split("/").last,
  //         audioPath: file.path,
  //         audioId: uuid.v1(),
  //       );
//
  //       // ====测试，新增到db一条，就给显示数字—+1
  //       setState(() {
  //         scannedAudioList.add(audioInfo);
  //       });
  //     }
  //   }
//
  //   // 4 将满足条件的音乐信息实例添加到数据库(如果数据库中已有同名、且同位置的，则不新增)
  //   for (var audioInfo in audioList) {
  //     var alreadyList = await audioDbHelper.queryLocalAudioInfo(
  //         audioName: audioInfo.audioName);
  //
  //     var alreadyFlag = false;
  //     for (var ele in alreadyList) {
  //       if (audioInfo.audioPath == ele.audioPath) {
  //         alreadyFlag = true;
  //         break;
  //       }
  //     }
//
  //     if (!alreadyFlag) {
  //       await audioDbHelper.insertLocalAudioInfo(audioInfo);
//
  //       // 也存到默认全局歌单去
  //       var audioPlayListInfo = LocalAudioPlaylist(
  //         audioId: audioInfo.audioId,
  //         audioPlaylistId: GlobalConstants.localAudioDeaultPlaylistId,
  //         audioPlaylistName: GlobalConstants.localAudioDeaultPlaylistName,
  //         audioName: audioInfo.audioName,
  //         audioPath: audioInfo.audioPath,
  //       );
//
  //       await audioDbHelper.insertLocalAudioPlaylist(audioPlayListInfo);
//
  //       // // ====测试，新增到db一条，就给显示数字—+1
  //       // setState(() {
  //       //   scannedAudioList.add(audioPlayListInfo);
  //       // });
  //     }
  //   }
//
  //   // 5 新增成功后，显示当前扫描的音频总数量
//
  //   setState(() {
  //     sacnLoading = false;
  //     // scannedAudioList = audioList;
  //   });
  // }
//
  // saveAudioFileToPlaylistDB(FileSystemEntity file) {
//
  // }

  DataRow getRow(int index, [Color? color]) {
// 将扫描到的音乐文件，配合索引，构建表格行数据
// scannedAudioList
// selectedAudioList
//
    return DataRow(
      selected: selectedAudioList.contains(scannedAudioList[index]),
      onSelectChanged: (bool? value) {
        print("33333333333$value");
        setState(() {
          if (value == false) {
            selectedAudioList.remove(scannedAudioList[index]);
          }
          if (value == true) {
            selectedAudioList.add(scannedAudioList[index]);
          }
        });

        print(selectedAudioList.length);
      },
      cells: [
        DataCell(
          Text(
            scannedAudioList[index].path.split("/").last,
            textAlign: TextAlign.left,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
          ),
          onTap: () {
            setState(() {
              color = Colors.lightBlueAccent;
            });
          },
        ),
        DataCell(
          Center(
            child: ListTile(
              title: Text(
                scannedAudioList[index].path.split("/").last,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
              subtitle: Text(
                scannedAudioList[index].path,
                textAlign: TextAlign.left,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12.sp),
              ),
            ),
          ),
          onTap: () {
            setState(() {
              color = Colors.lightBlueAccent;
            });
          },
        ),
        // 栏位是输入框的示例
        // const DataCell(
        //   TextField(
        //     decoration:
        //         InputDecoration(border: InputBorder.none, hintText: 'paine'),
        //   ),
        // ),
        // 放在row尾巴的操作按钮，点击弹出一些操作，比如加入歌单（会做）、稍后播放、详细……
        DataCell(
          IconButton(
            icon: const Icon(Icons.more_horiz),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // 必须是最外层组件，点击返回按钮在return true后才能返回数据
    return WillPopScope(
      onWillPop: () async {
        // 点击返回按钮之类的返回到主页面时，一并传回新加音乐的歌单，供刷新该歌单
        //  如果主页歌单不是这个新加入音频的歌单，就切成此歌单

        print("<<<<<<<<<$selectedPlaylistName");

        Navigator.pop(context, selectedPlaylistName);
        return true;
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                  Expanded(
                    flex: 4,
                    child: ElevatedButton(
                      onPressed: () => _scanAllLocalAudio(),
                      child: Text(
                        '全盘扫描  ${scannedAudioList.length}',
                        style: TextStyle(fontSize: 10.sp),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                ],
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
              Text(
                '扫描总数量  ${scannedAudioList.length}',
                style: TextStyle(fontSize: 10.sp),
              ),
              Text(
                '新增的数量  ${dbAudioInfoList.length}',
                style: TextStyle(fontSize: 10.sp),
              ),

              // 表格显示新扫描的歌曲
              // 最好有个多选框，做加入歌单功能
              // 或者每次扫描都列示全部，新增的放在上面，加个new的标识？

              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      dataRowHeight: 50.sp,
                      // 如果是复选框全选，则表示把扫描到的音频都要放到被选中列表去
                      // 如果全部取消，则清空被选音频列表
                      onSelectAll: (bool? value) {
                        print("onSelectAll$value");
                        setState(() {
                          if (value == true) {
                            selectedAudioList = [];
                            selectedAudioList.addAll(scannedAudioList);
                          }
                          if (value == false) {
                            selectedAudioList = [];
                          }
                        });

                        print(selectedAudioList.length);
                      },
                      columns: const [
                        DataColumn(label: Text('歌曲')),
                        DataColumn(label: Text('路径')),
                        DataColumn(label: Text('操作')),
                      ],
                      rows: List<DataRow>.generate(
                        scannedAudioList.length,
                        // 构建行数据用指定函数
                        (index) => getRow(index),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        /// 歌单管理不放在当前组件，这里改为搜索当前歌单指定歌曲
        floatingActionButton: FloatingActionButton(
          child: Icon(
            Icons.add_box,
            color: selectedAudioList.isEmpty ? Colors.grey : Colors.white,
          ),

          /// 点击添加按钮，把选择的歌曲加入到指定歌单
          ///       如果没有被选中的歌曲，按钮不可点击
          onPressed: selectedAudioList.isEmpty
              ? null
              : () {
                  print("-------currentPlaylistName---");

                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      // 后续这些dialog等通用配置可以单独列，不要这样到处size都不同
                      return AlertDialog(
                        title: Text(
                          "添加到歌单:",
                          style: TextStyle(fontSize: 18.sp),
                        ),
                        content: SizedBox(
                          width: 160.sp,
                          child: DropdownSearch<String>(
                            // 单模式弹出窗口的自定义道具
                            popupProps: PopupProps.menu(
                              showSelectedItems: true,
                              disabledItemFn: (String s) => s.startsWith('I'),
                              // 默认是 FlexFit.tight，填满所有可用空间，改为loose，则只显示已占用高度
                              fit: FlexFit.loose,
                            ),
                            items: allPlaylist,
                            onChanged: (playlistName) {
                              setState(() {
                                selectedPlaylistName = playlistName ?? "";
                              });
                            },
                            // 音乐播放主页默认是我的最爱列表，这里的值注意和initData一致
                            selectedItem: selectedPlaylistName,
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text(
                              '取消',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              print("-------audioSaerchController---");
                              // 将选中的音频加入被选中的歌单去
                              addSelectedAudioListToSelectedPlaylist();

                              if (isAddingToPlaylist) {
                                Fluttertoast.showToast(
                                    msg: "加入歌单完成!",
                                    toastLength: Toast.LENGTH_SHORT);
                                Navigator.of(context).pop();
                              }
                            },
                            child: Text(
                              '确定',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          ),
                        ],
                      );
                    },
                  );
                },
        ),
      ),
    );
  }
}
