// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

// import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/utils/sqlite_helper.dart';
import 'package:freader/views/txt_viewer/handle_asset_txt_to_db.dart';
import 'package:freader/views/txt_viewer/txt_screen.dart';

/// 相较于pdf viewer，这个就简单弄个demo
/// 2022-05-16 本来，现在不管，每次进来都从新开始，也沒有书签记录
/// 解析內置的4大名著txt，不进行其他自选或者扫描
/// 解析的过程可能比较复杂，还需考虑是否把txt按照章节解析数据存入db，还一个记录阅读进度信息
///
class TxtViewerPage extends StatefulWidget {
  const TxtViewerPage({Key? key}) : super(key: key);

  @override
  State<TxtViewerPage> createState() => _TxtViewerPageState();
}

class _TxtViewerPageState extends State<TxtViewerPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  var txtList = [
    "A Dream of Red Mansions",
    "The Journey to the West",
    "Romance of the Three Kingdoms",
    "Water Margin"
  ];

  // var txtFullContent = "";
  // loadTxtData() async {
  //   var t1 = DateTime.now();
  //   print(DateTime.now());
  //   final data = await rootBundle
  //       .loadString('assets/txts/A_Dream_of_Red_Mansions-utf8.txt');
  //   print("---------");
  //   print(DateTime.now());
  //   var t2 = DateTime.now();
  //   print(t2.difference(t1).inMicroseconds);

  //   // print(data);
  //   setState(() {
  //     txtFullContent = data;
  //   });
  // }

  loadData() async {
    // _databaseHelper.deleteDb();
    // 如果db中txtstate不违空，就判断為已有數據了
    var tempList = await _databaseHelper.readTxtStateList();

    // 其实应该大于120*3+100+4個引子的数量（464）就可以判断為重复倒入了
    if (tempList.isEmpty || tempList.length > 470) {
      _databaseHelper.deleteAllTxtState();
      handleAssetTxt2Db("红楼梦");
      handleAssetTxt2Db("三国演义");
      handleAssetTxt2Db("西游记");
      handleAssetTxt2Db("水浒传");
    } else {
      print("数据都已经存在数据库了");
    }
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return _buildTxtGriwView(txtList);
  }
}

// 构建txt griw列表
_buildTxtGriwView(List<String> txtList) {
  return GridView.builder(
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      childAspectRatio: 4 / 2, // item的宽高比
      crossAxisCount: 2,
    ),
    itemCount: txtList.length, // 文件的数量
    itemBuilder: (BuildContext context, int index) {
      return GestureDetector(
        onTap: () => _onPdfCardTap(txtList[index], context),
        child: SizedBox(
          child: Card(
            color: Colors.lightGreen,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    txtList[index],
                    maxLines: 3,
                    style: TextStyle(fontSize: 10.sp),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

_onPdfCardTap(String title, BuildContext context) async {
  // 非特殊情況，跳转到指定页面
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext ctx) {
        return TxtScreen(
          title: title,
        );
      },
    ),
  ).then((value) {
    print("这是跳转路由后返回的数据： $value");
    // 在TXT viewer页面返回后，重新获取TXT list，更新阅读进度
  });
}
