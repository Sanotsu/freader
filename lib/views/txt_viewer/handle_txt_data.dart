// ignore_for_file: avoid_print
import 'dart:io';

import 'dart:convert';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// 2022-05-16
/// 本来打算是逐行解析数据，把标题和每回的內容整理存入数据库。但是无法正确匹配，每行的內容也没能正确处理
/// 后续有时间再搞

handleTxtData() async {
  // var t1 = DateTime.now();
  // print(DateTime.now());
  // final data = await rootBundle
  //     .loadString('assets/txts/A_Dream_of_Red_Mansions-utf8.txt');
  // print("---------");
  // print(DateTime.now());
  // var t2 = DateTime.now();
  // print(t2.difference(t1).inMicroseconds);

  // print(data);

  var filePath = p.join(Directory.current.path, 'assets',
      'txts/A_Dream_of_Red_Mansions-utf8.txt');

  print(filePath);

// 从asset读取文件并保存到file
/**
 * 1 create a new File-path to your Documents-directory (named app.txt in the below code-example)
   2 copy the File sitting in your assets folder to this Documents-directory location
   3 work with the copied file from now on (where you now have File-path and even Byte-content if needed)
 */
  Directory directory = await getApplicationDocumentsDirectory();
  var dbPath = p.join(directory.path, "app.txt");
  ByteData data =
      await rootBundle.load("assets/txts/A_Dream_of_Red_Mansions-utf8.txt");
  List<int> bytes =
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
  var file = await File(dbPath).writeAsBytes(bytes);

  // file.openRead().transform(utf8.decoder).forEach((l) => print('line: $l'));

  /// 这两者的行数完全不一样
  var index = 0;
  file.openRead().transform(utf8.decoder).forEach((l) {
    print('line$index:  $l');
    index++;
  });

  var titleList = [];

  List<String> lines = file.readAsLinesSync();
  for (var i = 0; i < lines.length; i++) {
    var line = lines[i];
    var content = "";
    print("第$i行,內容为 ${lines[i]}");

    // 不会正则，讲究用吧
    if (line.contains(RegExp(r'[第].[回]|[第]..[回]|[第]...[回]'))) {
      titleList.add(line);
    } else {
      content += line;
    }
    print(content);
  }

  print(titleList);

  // file.openRead().transform(utf8.decoder).forEach((line) {
  //   var title = "";
  //   var content = "";
  //   // 如果读到了标题行，则保存，否则累加
  //   if (line.contains("第一回")) {
  //     title = line;
  //     content = "";
  //     titleList.add(title);
  //   } else {
  //     content += line;
  //   }

  //   print(titleList);
  // });

  // print(titleList);

  var test = "上卷 第一回  甄士隐梦幻识通灵　贾雨村风尘怀闺秀";
  var test2 = "上卷 第五十回  甄士隐梦幻识通灵　贾雨村风尘怀闺秀";
  var test3 = "上卷  第一一八回   甄士隐梦幻识通灵　贾雨村风尘怀闺秀";

  print("1111 ${test.contains(RegExp(r'[第].[回]|[第]..[回]|[第]...[回]'))}");
  print("2222 ${test2.contains(RegExp(r'[第].[回]|[第]..[回]|[第]...[回]'))}");
  print("333 ${test3.contains(RegExp(r'[第].[回]|[第]..[回]|[第]...[回]'))}");
}
