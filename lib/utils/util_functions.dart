// ignore_for_file: avoid_print

import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<String> createAlbumCacheDirectory(String url) async {
  requestPermission();
  final filepath = await getApplicationDocumentsDirectory();
  var file = Directory(filepath.path + "/" + url);
  try {
    bool exists = await file.exists();
    if (!exists) {
      await file.create();
      print("创建成功");
    } else {
      print("已存在");
    }
  } catch (e) {
    print(e);
  }
  return file.path.toString();
}

// 获取存储权限
requestPermission() async {
  await [Permission.storage].request();

  // Map<Permission, PermissionStatus> statuses = await [
  //   Permission.storage,
  // ].request();

  // final info = statuses[Permission.storage].toString();
  // print("获取存取权限--------------$info");
}
