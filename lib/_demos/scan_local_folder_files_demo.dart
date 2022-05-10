// ignore_for_file: avoid_print

import 'dart:io' as io;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 2022-5-10 使用debug模式，app上开启权限之后，可以看到 /storage/emulated/0/Download 等文件夹的文件，
/// 使用run不一定有
///
void main() => runApp(const ScanLocalFolderFilesWidget());

class ScanLocalFolderFilesWidget extends StatefulWidget {
  const ScanLocalFolderFilesWidget({Key? key}) : super(key: key);

  @override
  State<ScanLocalFolderFilesWidget> createState() =>
      _ScanLocalFolderFilesWidgetState();
}

class _ScanLocalFolderFilesWidgetState
    extends State<ScanLocalFolderFilesWidget> {
  //Declare Globaly
  late String directory;
  List singleDirFiles = [];

// 设备种的所有文件
  List allDirFiles = [];
  @override
  void initState() {
    super.initState();
    _listofFiles();
  }

  // Make New Function
  void _listofFiles() async {
    directory = (await getApplicationDocumentsDirectory()).path;

    var temporary = await getTemporaryDirectory();
    var applicationSupport = await getApplicationSupportDirectory();
    // var library = await getLibraryDirectory();
    var applicationDocuments = (await getApplicationDocumentsDirectory()).path;
    var externalStorage = await getExternalStorageDirectory();
    var externalCache = await getExternalCacheDirectories();
    var externalStorages = await getExternalStorageDirectories();
    // var downloads = await getDownloadsDirectory();

    print("--------------");
    print(directory);
    print("--------------");
    print(temporary);
    print("--------------");
    print(applicationSupport);
    print("--------------");
    // print(library);
    // print("--------------");
    print(applicationDocuments);
    print("--------------");
    print(externalStorage);
    print("--------------");
    print(externalCache);
    print("--------------");
    print(externalStorages);
    // print("--------------");
    // print(downloads);
    print("--------------");

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
    setState(() {
      singleDirFiles = io.Directory(directory)
          .listSync(recursive: true); //use your folder name insted of resume.

      // 获取所有第一级文件夹
      var dir = Directory('/storage/emulated/0/');
      var listOfAllFolderAndFiles = dir.listSync();
      print(listOfAllFolderAndFiles);

      // 因为 /storage/emulated/0/Android 没有权限掃描，所以其他的再递归掃描

      for (var folder in listOfAllFolderAndFiles) {
        print("folder.path---${folder.path}");
        if (folder.path != '/storage/emulated/0/Android') {
          allDirFiles.addAll(Directory(folder.path).listSync(recursive: true));
          print("allDirFiles.changdu ---${allDirFiles.length}");
        }
      }

      for (var folder in listOfAllFolderAndFiles) {
        if (folder.path == '/storage/emulated/0/Download') {
          print(
              "000000000  ${Directory(folder.path).listSync(recursive: true).length}");
        }
      }
      print("=============================${allDirFiles.length}");
      print(allDirFiles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'List of Files',
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Get List of Files with whole Path"),
        ),
        body: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  // your Content if there
                  Expanded(
                    child: ListView.builder(
                        itemCount: singleDirFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(
                            singleDirFiles[index].toString(),
                            style: const TextStyle(fontSize: 8),
                          );
                        }),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                children: <Widget>[
                  // your Content if there
                  Expanded(
                    child: ListView.builder(
                        itemCount: allDirFiles.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Text(
                            allDirFiles[index].toString(),
                            style: const TextStyle(fontSize: 8),
                          );
                        }),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
