// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:freader/views/markdown_view/markdown_widget_screen.dart';
// import 'package:freader/views/markdown_viewer/flutter_markdown_screen.dart';

import 'dart:convert';

/// 2022-05-05
/// 目前支持或计划支持的开源的新闻api，就会放到这个titles中，点击对应的card，跳转到具体网站的页面，查看详情内容

// 为了分组列表准备的类
class GroupListObject {
  // 文章标题
  final String title;
  // 列表分组关键字
  final String groupKey;
  // 文章在asset的路径
  final String articlePath;

  GroupListObject(this.title, this.groupKey, this.articlePath);
}

class MarkdownPage extends StatefulWidget {
  const MarkdownPage({Key? key}) : super(key: key);

  @override
  State<MarkdownPage> createState() => _MarkdownPageState();
}

class _MarkdownPageState extends State<MarkdownPage> {
  // 文章分组列表
  List<GroupListObject> titleGroupList = [];

  // md文件所在asset的路径
  String mdAssetPath = 'assets/mds';

  /// 获取asset指定文件夹中的文件，读取md文件列表
  getMarkdownFileList() async {
    // 读取文件列表
    final manifestJson =
        await DefaultAssetBundle.of(context).loadString('AssetManifest.json');

    List<String> mdList = List<String>.from(json
        .decode(manifestJson)
        .keys
        .where((String key) => key.startsWith(mdAssetPath)));

    // 构建临时的分组列表
    List<GroupListObject> tempGroupList = [];

    for (String e in mdList) {
      var tempArr = e.split("/");
      print("tempArr[tempArr.length - 1]${tempArr[tempArr.length - 1]}");

      // 2022-07-05 理论上，md的文章在 assets/mds/<类别>/xxx.md，也就是4层，
      // 所以大于4层的应该是文章的附件，例如图片等，就不显示了。
      // 可能有直接放在最外面的文章，就不限制等于4了。
      if (tempArr.length > 4) {
        continue;
      }
      tempGroupList.add(
        GroupListObject(
          // 路径中文是转码后的，所以要转码回来才能看懂是什么（2023-3-31新版本转了还会报错）
          tempArr[tempArr.length - 1],
          // Uri.decodeComponent(tempArr[tempArr.length - 1]), // 文章标题
          tempArr[tempArr.length - 2], // 分类
          e,
          // Uri.decodeComponent(e), // asset完整路径
        ),
      );
    }

    setState(() {
      titleGroupList = tempGroupList;
    });
  }

  @override
  void initState() {
    getMarkdownFileList();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GroupedListView<GroupListObject, String>(
            // 分类对象数组
            elements: titleGroupList,
            // 分类的关键字
            groupBy: (element) => element.groupKey,
            // 分组排序
            groupComparator: (value1, value2) => value2.compareTo(value1),
            // 分组内部排序
            itemComparator: (item1, item2) =>
                item1.title.compareTo(item2.title),
            // 列表的顺序
            order: GroupedListOrder.ASC,
            useStickyGroupSeparators: true,
            // 分类分组的设置
            groupSeparatorBuilder: (String value) => Padding(
              padding: EdgeInsets.all(10.0.sp),
              child: Text(
                value,
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            itemBuilder: (c, element) {
              return Card(
                // 控制card下方的阴影大小
                // elevation: 8.0,
                // 子分类间隔(间隔太宽不好看)
                margin: EdgeInsets.symmetric(
                  horizontal: 0.0.sp,
                  vertical: 1.0.sp,
                ),
                // 子分类主体内容
                child: SizedBox(
                  child: ListTile(
                    // 间隔太宽不好看
                    // contentPadding: EdgeInsets.symmetric(
                    //   horizontal: 10.0.sp,
                    //   vertical: 10.0,
                    // ),
                    title: Text(
                      element.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.lightBlue,
                      ),
                    ),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () => _onCardTap(context, element.articlePath),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

_onCardTap(BuildContext context, String mdUrl) {
  Navigator.of(context).push(
    MaterialPageRoute(
      builder: (BuildContext context) {
        return MarkdownWidgetScreen(mdAssetPath: mdUrl);
      },
    ),
  );
}
