// ignore_for_file: avoid_print

import 'dart:io';

import 'package:freader/common/personal/constants.dart';
import 'package:freader/common/utils/sqlite_audio_helper.dart';
import 'package:freader/models/app_embedded/local_audio_state.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

///
/// 音乐相关的接口
/// 1 随机网易云音乐:
///     https://www.free-api.com/doc/302      json文件
///     https://www.hlapi.cn/doc/wyrb.html   直接音乐
///

/// 获取设备本地已有的音频文件
/// （扫描过程真应该做成一个组件，可以随时查看扫描的位置路径，比一直转圈圈好）
Future<List<LocalAudioInfo>> scanAllLocalAudio() async {
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
  List<LocalAudioInfo> audioList = [];

  // 1 获取存储权限
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

  print("11111111111111111111111$allRootFSEList");

  // 临时获取所有文件夹的所有文件
  List<FileSystemEntity> tempList = [];

  // 因为 /storage/emulated/0/Android 没有权限掃描，所以其他的再递归掃描
  for (var fse in allRootFSEList) {
    // 为了方便看清楚，才延迟显示1秒
    await Future.delayed(const Duration(microseconds: 100));

    // 如果是根文件夹下的文件，则直接加入list
    if (fse.runtimeType.toString() == "_File") {
      tempList.add(fse);
    }

    // 如果是文件夹，且不为没权限扫描的文件夹,则递归便利其文件夹，把文件加入list，不是文件则忽略
    if (fse.runtimeType.toString() == "_Directory" &&
        !noPermissionDirList.contains(fse.path)) {
      await Directory(fse.path).list(recursive: true).forEach((f) {
        if (f.runtimeType.toString() == "_File") {
          tempList.add(f);
        }
      });
    }
    // 其他的例如link，就不管了
  }

  // 重新扫描时，先清空
  audioList = [];

  // 3 筛选满足后缀条件的文件构建音乐信息实例
  for (var file in tempList) {
    if (fileExtensionList.contains(path.extension(file.path).toLowerCase())) {
      // 构建数据实例
      var audioInfo = LocalAudioInfo(
        audioName: file.path.split("/").last,
        audioPath: file.path,
        audioId: uuid.v1(),
      );
      audioList.add(audioInfo);
    }
  }

  // 4 将满足条件的音乐信息实例添加到数据库(如果数据库中已有同名、且同位置的，则不新增)
  for (var audioInfo in audioList) {
    var alreadyList =
        await audioDbHelper.queryLocalAudioInfo(audioName: audioInfo.audioName);

    var alreadyFlag = false;
    for (var ele in alreadyList) {
      if (audioInfo.audioPath == ele.audioPath) {
        alreadyFlag = true;
        break;
      }
    }

    if (!alreadyFlag) {
      await audioDbHelper.insertLocalAudioInfo(audioInfo);

      // 也存到默认全局歌单去
      var audioPlayListInfo = LocalAudioPlaylist(
        audioId: audioInfo.audioId,
        audioPlaylistId: GlobalConstants.localAudioDeaultPlaylistId,
        audioPlaylistName: GlobalConstants.localAudioDeaultPlaylistName,
        audioName: audioInfo.audioName,
        audioPath: audioInfo.audioPath,
      );

      // 测试，加几首歌到我的最爱
      // if (audioInfo.audioName.length > 40) {
      //   // 也存到默认全局歌单去
      //   var audioPlayListInfo2 = LocalAudioPlaylist(
      //     audioId: audioInfo.audioId,
      //     audioPlaylistId: GlobalConstants.localAudioMyFavoriteId,
      //     audioPlaylistName: GlobalConstants.localAudioMyFavoriteName,
      //     audioName: audioInfo.audioName,
      //     audioPath: audioInfo.audioPath,
      //   );
      //   await audioDbHelper.insertLocalAudioPlaylist(audioPlayListInfo2);
      // }

      // print(audioPlayListInfo);
      // print("_____________MMMMMMMMM");

      // break;
      await audioDbHelper.insertLocalAudioPlaylist(audioPlayListInfo);
    }
  }

  print("2sssssssds222222--${audioList.length}");

  // 返回扫描出来并成功加入db的音频信息列表
  return audioList;
}
