// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/today_in_history_result.dart';
import 'package:freader/views/tools_view/fetch_today_in_history_result.dart';

import 'package:freader/widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class TodayInHistoryScreen extends StatefulWidget {
  const TodayInHistoryScreen({Key? key}) : super(key: key);

  @override
  State<TodayInHistoryScreen> createState() => _TodayInHistoryScreenState();
}

class _TodayInHistoryScreenState extends State<TodayInHistoryScreen> {
  //每次获取的数据列表要展示的数据
  late Future<List<TodayInHistoryResultData>> futureList;
  // 已经获取到的数据
  List<TodayInHistoryResultData> acquiredList = [];
  //是否正在加载数据
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureList = _getTodayInHistoryList();
  }

  ///下拉刷新
  // 下拉刷新获取最新的数据，也就是第一页的数据
  Future<List<TodayInHistoryResultData>> _getTodayInHistoryList() async {
    acquiredList.clear();

    var response = await fetchTodayInHistoryResult();
    acquiredList.addAll(response);

    setState(() {
      isLoading = false;
    });
    return acquiredList;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('历史上的今天'),
      ),
      body: Builder(builder: (BuildContext context) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Center(
                child: Text(
                  """今天是${DateFormat('yyyy-MM-dd').format((DateTime.now().toLocal()))}，历史上的今天有哪些重大事件呢？""",
                  style: TextStyle(fontSize: 14.sp),
                ),
              ),
            ),
            Expanded(
              flex: 9,
              child: FutureBuilder<List<TodayInHistoryResultData>>(
                future: futureList,
                builder: (context,
                    AsyncSnapshot<List<TodayInHistoryResultData>> snapshot) {
                  ///正在请求时的视图
                  if (snapshot.connectionState == ConnectionState.active ||
                      snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Text("loading..."),
                    );
                  }

                  /// 已经加载完成
                  if (snapshot.connectionState == ConnectionState.done) {
                    // 如果正常获取数据，且数据不为空
                    if (snapshot.hasData &&
                        snapshot.data != null &&
                        snapshot.data!.isNotEmpty) {
                      // 这里snapshot.data就是 acquiredList
                      List? data = snapshot.data;
                      return Center(
                        child: ListView.builder(
                          itemCount: data!.length,
                          itemBuilder: (BuildContext context, int index) {
                            // 如果当前显示的索引小于list的數量，正常显示;否则，显示正在加载新数据
                            return index < data.length
                                ? _buildItemCard(data[index])
                                : const LoadingMoreWidget();
                          },
                        ),
                      );
                    } else if (snapshot.hasError) {
                      /// 如果请求数据有错，显示错误信息
                      return Text('${snapshot.error}');
                    } else {
                      // 如果正常获取数据，
                      //  還在加载中，显示loading
                      //  已经加载完了还是没有数据，显示 empty
                      return Center(
                        child: isLoading
                            ? const Text("loading ...")
                            : const Text("empty or null data"),
                      );
                    }
                  }

                  // By default, show a loading spinner.
                  return const CircularProgressIndicator();
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}

// 历史上的今天每条数据的处理
Widget _buildItemCard(TodayInHistoryResultData item) {
  return Container(
    height: 45.sp,
    color: Colors.white,
    child: Card(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // 时间字串
          Text(
            "${item.year}年",
            style: TextStyle(fontSize: 12.sp),
          ),
          // 标题和摘要之间的空行
          SizedBox(
            width: 30.sp,
          ),
          // 标题最多也1行显示，缩放为1.0. 目前是点击标题，跳转第newsAggList的第一个链接
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RichText(
                  maxLines: 2,
                  textScaleFactor: 1,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        // 不指定颜色可能默认为白色，看不见，像是没有内容一样(Theme.of()本身返回TextStyle)
                        // style: Theme.of(context).textTheme.bodyText2,
                        style:
                            TextStyle(color: Colors.lightBlue, fontSize: 12.sp),
                        text: item.title,
                        recognizer: TapGestureRecognizer()
                          ..onTap = () async {
                            // 如果有直接的url属性，则是非热门话题，直接取得；否则就是热门话题，从关联新闻中取第一个
                            var url = Uri.parse(item.link);
                            // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.inAppWebView,
                                webViewConfiguration:
                                    const WebViewConfiguration(
                                  enableJavaScript: true,
                                  enableDomStorage: true,
                                ),
                              );
                            } else {
                              throw 'Could not launch $url';
                            }
                          },
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          // Text(
          //   item.type,
          //   style: TextStyle(color: Colors.lightBlue, fontSize: 12.sp),
          // ),
        ],
      ),
    ),
  );
}
