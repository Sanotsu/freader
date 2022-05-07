// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/zhihu_api_daily_result.dart';
import 'package:date_format/date_format.dart';
import 'package:freader/views/readhub_category/readhub_common_widgets.dart';
import 'package:freader/views/zhihu_category/fetch_zhihu_daily_result.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: slash_for_doc_comments
/**
 * flutter_datetime_picker 来选择日期
 */

class ZhihuDailyNews extends StatefulWidget {
  const ZhihuDailyNews({Key? key}) : super(key: key);

  @override
  State<ZhihuDailyNews> createState() => _ZhihuDailyNewsState();
}

class _ZhihuDailyNewsState extends State<ZhihuDailyNews> {
  //每次获取的数据列表要展示的数据（ZhihuApiDailyResult中的stories）
  late Future<List<StoriesData>> futureZhihuDailyResult;
  // 已经获取到的数据
  List<StoriesData> acquiredList = [];
  // 记录最新<当前日期+1>(url中before后一天的数据才是当天的数据)
  final latesetDate =
      formatDate(DateTime.now().add(const Duration(days: 1)), [yyyy, mm, dd]);
  // 当前查询日期字符串
  var currentDate = "";
  // 当前查询日期返回结果中的date
  var dailyDate = "";

  //是否正在加载数据
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureZhihuDailyResult = _getLatestItemNews();
  }

  ///下拉刷新
  // 下拉刷新获取最新的数据，也就是第一页的数据
  Future<List<StoriesData>> _getLatestItemNews() async {
    acquiredList.clear();
    currentDate = latesetDate;

    print("开始获取最新消息...");
    var response = await fetchZhihuDailyResult(currentDate);

    setState(() {
      dailyDate = response.date;
    });

    acquiredList.addAll(response.stories);
    return acquiredList;
  }

  @override
  Widget build(BuildContext context) {
    var ri = RefreshIndicator(
      // 下拉刷新就是加载最新一页的数据
      onRefresh: _getLatestItemNews,
      child: FutureBuilder<List<StoriesData>>(
        future: futureZhihuDailyResult,
        builder: (context, AsyncSnapshot<List<StoriesData>> snapshot) {
          ///正在请求时的视图
          if (snapshot.connectionState == ConnectionState.active ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Text("loading..."),
            );
          }

          /// 已经加载完成
          if (snapshot.connectionState == ConnectionState.done) {
            print("snapshot.data!.length   ${snapshot.data!.length}");
            // 如果正常获取数据，且数据不为空
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              // 这里snapshot.data就是acquiredList
              List? data = snapshot.data;
              return Center(
                child: ListView.builder(
                  itemCount: data!.length,
                  itemBuilder: (BuildContext context, int index) {
                    print("当前index $index, 已获取的数据數量: ${data.length}");

                    // 如果当前显示的索引小于list的數量，正常显示;否则，显示正在加载新数据
                    return index < data.length
                        ? _buildZhihuDailyNewsItemCard(data[index])
                        : const LoadingMoreWidget();
                  },
                ),
              );
            } else if (snapshot.hasError) {
              /// 如果请求数据有错，显示错误信息
              return Text('${snapshot.error}');
            } else {
              // 如果正常获取数据，但数据为空
              return const Center(
                child: Text("empty or null data"),
              );
            }
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 5.sp, top: 10.sp, bottom: 5.sp),
            child: Text(
              dailyDate,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ),
          const Divider(),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 20.sp),
              child: ri,
            ),
          )
        ],
      ),
    );
  }
}

/// 构建知乎日报的每个news标题的card
Widget _buildZhihuDailyNewsItemCard(StoriesData item) {
  return Container(
    height: 70.sp,
    color: Colors.white,
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 标题最多也1行显示，缩放为1.0. 目前是点击标题，跳转第newsAggList的第一个链接
                RichText(
                  maxLines: 2,
                  textScaleFactor: 1,
                  text: TextSpan(children: [
                    TextSpan(
                        // 不指定颜色可能默认为白色，看不见，像是没有内容一样(Theme.of()本身返回TextStyle)
                        // style: Theme.of(context).textTheme.bodyText2,
                        style:
                            TextStyle(color: Colors.lightBlue, fontSize: 12.sp),
                        text: item.title,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            // 如果有直接的url属性，则是非热门话题，直接取得；否则就是热门话题，从关联新闻中取第一个
                            var url = item.url;
                            // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                            if (await canLaunch(url)) {
                              await launch(
                                url,
                                forceSafariVC: false,
                                forceWebView: false,
                                // enableDomStorage: true,
                                // enableJavaScript: true
                              );
                            } else {
                              throw 'Could not launch $url';
                            }
                          }),
                  ]),
                ),
                // 标题和摘要之间的空行
                SizedBox(
                  height: 6.sp,
                ),
                Text(
                  item.hint,
                  style: TextStyle(color: Colors.black, fontSize: 10.sp),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: Image.network(item.images[0]),
          ),
        ],
      ),
    ),
  );
}