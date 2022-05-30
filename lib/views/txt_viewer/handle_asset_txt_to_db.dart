// ignore_for_file: avoid_print
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:freader/common/utils/sqlite_helper.dart';
import 'package:freader/models/app_embedded/txt_state.dart';

import 'package:uuid/uuid.dart';

/// 2022-05-16
/// 本来打算是逐行解析数据，把标题和每回的內容整理存入数据库。但是无法正确匹配，每行的內容也没能正确处理
/// 后续有时间再搞

handleAssetTxt2Db(fileName) async {
  String data = await rootBundle.loadString('assets/txts/$fileName.txt');

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  var uuid = const Uuid();

  var index = 0;
  var titleList = [];
  // 引子先不管了
  var prefaceContent = "";
  var content = "";
  LineSplitter.split(data).forEach((line) {
    index++;
    // print('index $index -- $line');

    // prefaceContent += line;

    // 不会正则，将就用吧(匹配【第x回 】，x為1，2，3,4,5個字，回后面有个空个)
    if (line.contains(RegExp(
        r'[第].[回][\s]|[第]..[回][\s]|[第]...[回][\s]|[第]....[回][\s]|[第].....[回][\s]'))) {
      // print(index);

      var tempTxtState = TxtState(
          txtId: uuid.v1(),
          txtName: fileName,
          chapterId: uuid.v1(),
          chapterName: line,
          chapterContent: content,
          chapterContentLength: content.length);

      _databaseHelper.insertTxtState(tempTxtState);

      titleList.add(line);
      content = "";
    } else {
      content += line;
    }
    // print(content);
  });

  for (var e in titleList) {
    print(e);
  }
  print(titleList.length);
}
