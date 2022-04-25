// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/readhub_api_result.dart';
import 'package:freader/utils/platform_util.dart';
import 'package:freader/views/readhub_category/fetch_readhub_api_result.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadhubTopics extends StatefulWidget {
  const ReadhubTopics({Key? key}) : super(key: key);

  @override
  State<ReadhubTopics> createState() => _ReadhubTopicsState();
}

class _ReadhubTopicsState extends State<ReadhubTopics> {
  late Future<List<dynamic>> futureReadhubApiResult; //每次获取的数据列表要展示的数据
  List<ItemsData> acquiredList = []; // 已经获取到的数据
  var currentPage = 1; // 记录当前页面，下拉或者上拉的时候就要更新
  bool isLoading = false; //是否正在加载数据
  var size = 10; // 每页加载的數量

  late String url; // 当前请求的api的路径，page和size变化之后，要修改此url去获取新的数据

  // ignore: unused_field
  Future<void>? _launched;

  final ScrollController _scrollController = ScrollController(); //listview的控制器

  String _genUrl(int page) {
    url = "https://api.readhub.cn/topic/list?page=$page&size=$size";
    return url;
  }

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureReadhubApiResult = getItemNews();
    currentPage = 1;

// 上拉添加监听器（并不是滑倒手机屏幕底部就更新数据，而是当前页的数据加载完之后更新下一頁的数据）
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      print('滑动到了最底部 ---> $currentPage');
      _getMore();
    }
  }

  ///获取最新消息
  // 下拉刷新，也一直是第一页
  Future<List<dynamic>> getItemNews() async {
    acquiredList.clear();

    print("开始获取最新消息...");
    var response = await fetchReadhubApiResult(_genUrl(1));

    // addAll()里面必须也是一个List<>，而不是一个List<>?
    var temp = response[0].data!.items ?? [];
    acquiredList.addAll(temp);
    print("最新消息已获取完成.acquiredList长度: ${acquiredList.length}");

    return acquiredList;
  }

// 上拉加载更多
  Future _getMore() async {
    setState(() {
      isLoading = true;
    });

    print('加载更多  $isLoading');

    // 延迟5秒，看一下加载效果
    await Future.delayed(const Duration(seconds: 5));

    var response = await fetchReadhubApiResult(_genUrl(currentPage));
    // addAll()里面必须也是一个List<>，而不是一个List<>?
    var temp = response[0].data!.items ?? [];
    acquiredList.addAll(temp);
    // 获取完之后，更新當前頁数据
    currentPage++;

    setState(() {
      isLoading = false;
    });

    print('加载完成  $isLoading');
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: getItemNews,
      child: FutureBuilder<List<dynamic>>(
        future: futureReadhubApiResult,
        builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
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
                  itemCount: data!.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    print("当前index $index, 已获取的数据數量: ${data.length}");

                    // 如果当前显示的索引小于list的數量，正常显示;否则，显示正在加载新数据
                    return index < data.length
                        ? _buildItemCard(context, index, data)
                        : _getMoreWidget();
                  },
                  controller: _scrollController,
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
  }

  Widget _buildItemCard(BuildContext context, int index, List<dynamic>? data) {
    ItemsData newsItem = data![index];

    // 获取创建时间，如果是utc，则加8个小时显示成北京时间
    var createdTime = DateTime.parse(newsItem.createdAt ?? '');
    if (createdTime.isUtc) {
      createdTime = createdTime.add(const Duration(hours: 8));
    }

    return Container(
      height: 80,
      color: Colors.white,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 标题最多也1行显示，缩放为1.0. 目前是点击标题，跳转第newsAggList的第一个链接
            RichText(
              maxLines: 1,
              textScaleFactor: 1,
              text: TextSpan(children: [
                TextSpan(
                    // 不指定颜色可能默认为白色，看不见，像是没有内容一样(Theme.of()本身返回TextStyle)
                    // style: Theme.of(context).textTheme.bodyText2,
                    style: TextStyle(color: Colors.lightBlue, fontSize: 10.sp),
                    text: "$index --- ${newsItem.title}",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = "${newsItem.newsAggList![0].url}";
                        // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                        if (await canLaunch(url)) {
                          await launch(
                            url,
                            forceSafariVC: false,
                            forceWebView: false,
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
            // 摘要
            Expanded(
              flex: 1,
              child: Text(
                newsItem.summary ?? "",

                ///浏览器...显示异常
                overflow: PlatformUtil.isWeb
                    ? TextOverflow.fade
                    : TextOverflow.ellipsis,
                // 如果是手机，摘要显示2行
                maxLines: PlatformUtil.isMobile ? 2 : 5,
                strutStyle: StrutStyle(
                  forceStrutHeight: false,
                  height: 0.1.sp,
                  leading: 1,
                ),
                style: Theme.of(context).textTheme.caption!.copyWith(
                    letterSpacing: 1.0,
                    fontSize: 8.sp,
                    color: Theme.of(context)
                        .textTheme
                        .headline6!
                        .color!
                        .withOpacity(0.8)),
              ),
            ),
            // 发布时间，其他icon等
            Row(
              children: <Widget>[
                Expanded(
                  flex: 1,
                  // 发布时间格式化，加上发布的网站名称
                  child: Text(
                    DateFormat('yyyy-MM-dd HH:mm:ss').format(createdTime) +
                        "    " +
                        "${newsItem.siteNameDisplay} ",
                    textScaleFactor: 1.0,
                    maxLines: 2,

                    ///浏览器...显示异常
                    overflow: PlatformUtil.isWeb
                        ? TextOverflow.fade
                        : TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.caption!.copyWith(
                          fontSize: 8.sp,
                        ),
                  ),
                ),

                /// 都是預留而已
                // 分享
                SmallButtonWidget(
                  onTap: () => {},
                  tooltip: "share",
                  child: Icon(
                    Icons.share,
                    size: 10.sp,
                  ),
                ),
                // 更多链接
                SmallButtonWidget(
                  onTap: () => {},
                  tooltip: "link",
                  child: Icon(
                    Icons.link,
                    size: 10.sp,
                  ),
                ),
                // 查看详情web
                SmallButtonWidget(
                  onTap: () => {},
                  tooltip: "detail",
                  child: Icon(
                    Icons.details,
                    size: 10.sp,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 加载更多时显示的组件,给用户提示
  Widget _getMoreWidget() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(5.0.sp),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              '加载中...',
              style: TextStyle(fontSize: 8.0.sp),
            ),
            SizedBox(
              height: 15.sp,
              width: 15.sp,
              child: CircularProgressIndicator(
                backgroundColor: Colors.grey[200],
                valueColor: const AlwaysStoppedAnimation(Colors.blue),
                value: .7,
              ),
            ),
            // CircularProgressIndicator(
            //   strokeWidth: 1.0.sp,
            // )
          ],
        ),
      ),
    );
  }
}

///  都是預留的打开连接及关联报道Button
class SmallButtonWidget extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget child;
  final String tooltip;

  const SmallButtonWidget({
    Key? key,
    required this.onTap,
    required this.child,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(5.sp),
          child: child,
        ),
      ),
    );
  }
}
