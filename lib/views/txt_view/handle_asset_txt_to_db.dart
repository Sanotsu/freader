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
  // 小说章节行筛选使用的正则规则
  // var regRule = RegExp(
  //   r'[第].[回][\s]|[第]..[回][\s]|[第]...[回][\s]|[第]....[回][\s]|[第].....[回][\s]',
  // );

  /// 正则
  /// .       （小数点）默认匹配除换行符之外的任何单个字符。
  /// +       （加号）匹配前面一个表达式 1 次或者多次。等价于 {1,}。
  /// \s      匹配一个空白字符，包括空格、制表符、换页符和换行符。
  /// [xyz]   一个字符集合。匹配方括号中的任意字符，包括转义序列。
  ///  终上，匹配 “第XXXX章/回/篇” 这样的标题

  var regRule = RegExp(r'[第].+[回章篇][\s]');

  var uuid = const Uuid();
  // 加载txt文件
  String data = await rootBundle.loadString('assets/txts/$fileName.txt');
  // 处理一个txt文件，其txtId要保持一直
  var txtId = uuid.v1();
  var titleList = [];

  // 章节内容
  String content = "";
  // 章节标题
  String chapterName = "";
// 章节编号手动自增，方便读取上一章下一章
  int chapterId = 0;

  // 逐行读取txt的字符串
  LineSplitter ls = const LineSplitter();
  List<String> lines = ls.convert(data);

  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];

    // 如果是章节标题行
    // 不会正则，将就用吧(匹配【第x回 】，x為1，2，3,4,5個字，回后面有个空个)
    if (line.contains(regRule)) {
      /// 如果该标题和内容不为空
      if (chapterName != "" && content != "") {
        // 章节内容存入db
        var chapterNameCopy = json.decode(json.encode(chapterName));
        var cloneCopy = json.decode(json.encode(content));

        await savechapterToDB(
          txtId,
          fileName,
          chapterId.toString(),
          chapterNameCopy,
          cloneCopy,
        );

        titleList.add(chapterName);
        // 然后清空内容，保留标题供应对下一节的内容
        content = "";
        chapterName = line;
        chapterId++;
      } else {
        //  如果该标题和内容不全,仅记录该章节标题
        chapterName = line;
        chapterId++;
      }
    } else {
      // 如果是正文内容行，累加该行到章节正文中(加入换行符)
      content += "$line\n";
    }
    // 最后一行读完后，最后一章的标题和内容还在外面，没有存入db
    if (i == lines.length - 1) {
      await savechapterToDB(
        txtId,
        fileName,
        chapterId.toString(),
        json.decode(json.encode(chapterName)),
        json.decode(json.encode(content)),
      );
      titleList.add(chapterName);
    }
  }

  // for (var e in titleList) {
  //   print(e);
  // }
  // print(titleList.length);
}

// 把章节内容存到db
savechapterToDB(
  String txtId,
  String fileName,
  String chapterId,
  String chapterNameCopy,
  String cloneCopy,
) async {
  final DatabaseHelper databaseHelper = DatabaseHelper();

  var tempTxtState = TxtState(
      txtId: txtId,
      txtName: fileName,
      // 2022-06-4 为了方便读取下一章上一章，还是修改chapterId为自增的值
      chapterId: chapterId,
      chapterName: chapterNameCopy,
      chapterContent: cloneCopy,
      chapterContentLength: cloneCopy.length);

  // print(tempTxtState.toString());

  await databaseHelper.insertTxtState(tempTxtState);
}
