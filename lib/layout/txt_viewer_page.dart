// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/utils/sqlite_helper.dart';
import 'package:freader/models/app_embedded/txt_state.dart';
import 'package:freader/views/txt_view/handle_asset_txt_to_db.dart';
import 'package:freader/views/txt_view/txt_screen_pageview.dart';

/// 相较于pdf viewer，这个就简单弄个demo
/// 2022-05-16 本来，现在不管，每次进来都从新开始，也沒有书签记录
/// 解析內置的4大名著txt，不进行其他自选或者扫描
/// 解析的过程可能比较复杂，还需考虑是否把txt按照章节解析数据存入db，还一个记录阅读进度信息
///

class SimpleTxtState {
  final String txtId;
  final String txtName;
  final UserTxtState? userTxtState;
  const SimpleTxtState({
    required this.txtId,
    required this.txtName,
    this.userTxtState,
  });
}

class TxtViewerPage extends StatefulWidget {
  const TxtViewerPage({Key? key}) : super(key: key);

  @override
  State<TxtViewerPage> createState() => _TxtViewerPageState();
}

class _TxtViewerPageState extends State<TxtViewerPage> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  List<SimpleTxtState> txtList = [];

  var txtLoading = false;

  loadData() async {
    setState(() {
      txtLoading = true;
    });

    // 如果都没有就删除,会出问题?
    // _databaseHelper.deleteDb();
    // 如果db中txtstate不违空，就判断為已有數據了
    var tempList = await _databaseHelper.readTxtStateList();

    // 其实应该大于120*3+100+1個引子的数量（461）就可以判断為重复倒入了
    // 章节总计
    var chapterTotal = 120 + 120 + 121 + 100 + 9;
    if (tempList.isEmpty || tempList.length > chapterTotal) {
      _databaseHelper.deleteAllTxtState();
      await handleAssetTxt2Db("红楼梦");
      await handleAssetTxt2Db("三国演义");
      await handleAssetTxt2Db("水浒传");
      await handleAssetTxt2Db("西游记");
      // await handleAssetTxt2Db("阿Q正传");
    } else {
      print("数据都已经存在数据库了,全db章节数量: ${tempList.length}");

      // 以下都是打印出来看内容的，可以删除
      // _databaseHelper.showTableNameList();
      // List<TxtState> a = await _databaseHelper.readTxtStateList();
      // for (var e in a) {
      //   print("${e.txtId} -  ${e.txtName} - ${e.chapterId} - ${e.chapterName}");
      // }
    }

    // 查询当前有多少Txt，用于列表显示
    var tempTxtList = await _databaseHelper.readTxtStateList();

// 过滤重复的txt id和name，但值只保留id和name
    List<SimpleTxtState> listIdList = [];
    var list = [];
    for (var element in tempTxtList) {
      if (!list.contains(element.txtName)) {
        list.add(element.txtName);

        // 查询该txt有没有被阅读过(有阅读过，传给子组件就是阅读记录状态，否则只是txt编号，默认开始读第一章)
        List<UserTxtState> utsList =
            await _databaseHelper.queryUserTxtStateByTxtId(element.txtId);

        if (utsList.isNotEmpty) {
          listIdList.add(SimpleTxtState(
            txtId: element.txtId,
            txtName: element.txtName,
            userTxtState: utsList.first,
          ));
        } else {
          listIdList.add(SimpleTxtState(
            txtId: element.txtId,
            txtName: element.txtName,
          ));
        }
      }
    }

    setState(() {
      txtList = listIdList;
      txtLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    return txtLoading
        ? const Center(child: CircularProgressIndicator())
        : _buildTxtGriwView(txtList);
  }

// 构建txt griw列表
  _buildTxtGriwView(List<SimpleTxtState> txtList) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        childAspectRatio: 4 / 2, // item的宽高比
        crossAxisCount: 2,
      ),
      itemCount: txtList.length, // 文件的数量
      itemBuilder: (BuildContext context, int index) {
        var a = txtList[index].userTxtState?.currentChapterId;
        var b = txtList[index].userTxtState?.currentChapterPageNumber;
        var progressText =
            a != null ? "已读到第$a章 第${int.parse(b!) + 1}页" : "暂无阅读记录";

        return GestureDetector(
          onTap: () => _onPdfCardTap(context, txtList[index]),
          child: SizedBox(
            child: Card(
              color: Colors.lightGreen,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Text(
                        txtList[index].txtName,
                        maxLines: 3,
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Divider(
                      height: 5.sp,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      progressText,
                      style: TextStyle(
                        fontSize: 10.sp,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      "上次阅读时间: ${(txtList[index].userTxtState?.lastReadDatetime) ?? "暂无"}",
                      style: TextStyle(
                        fontSize: 10.sp,
                      ),
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

  _onPdfCardTap(BuildContext context, SimpleTxtState sts) async {
    // print(sts.userTxtState);
    // print(sts.txtId);
    // print(sts.txtName);

    // 非特殊情況，跳转到指定页面
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext ctx) {
          return sts.userTxtState != null
              ? TxtScreenPageView(
                  userTxtState: sts.userTxtState,
                )
              : TxtScreenPageView(
                  txtId: sts.txtId,
                );
        },
      ),
    ).then((value) {
      print("这是跳转路由后返回的数据： $value");
      // 在TXT viewer页面返回后，重新获取TXT list，更新阅读进度
      loadData();
    });
  }
}
