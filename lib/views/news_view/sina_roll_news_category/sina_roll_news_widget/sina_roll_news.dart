// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/sina_roll_news_result.dart';
import 'package:freader/widgets/global_styles.dart';
import 'package:freader/utils/platform_util.dart';
import 'package:freader/views/news_view/sina_roll_news_category/sina_roll_news_widget/fetch_sina_roll_news_result.dart';
import 'package:freader/widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class SinaRollNews extends StatefulWidget {
  const SinaRollNews({Key? key}) : super(key: key);

  @override
  State<SinaRollNews> createState() => _SinaRollNewsState();
}

class _SinaRollNewsState extends State<SinaRollNews> {
  //每次获取的数据列表要展示的数据
  late Future<List<dynamic>> futureSinaRollNewsResult;
  // 已经获取到的数据
  List<DataData> acquiredList = [];
  // 记录当前页面，下拉或者上拉的时候就要更新
  var currentPage = 1;
  //是否正在加载数据
  bool isLoading = false;
  // 每页加载的數量
  var size = 20;
  // 当前请求的api的路径，page和size变化之后，要修改此url去获取新的数据
  late String url;
  //listview的控制器，侦听上拉加载更多数据
  final ScrollController _scrollController = ScrollController();

  // 根据传入的新闻类型，构建对应的请求接口
  String _genUrl(int page) {
// 2022-07-04 注意这些路径的参数，这几个id确实不知道具体什么意思，但不能没有
    // https: //feed.mix.sina.com.cn/api/roll/get?pageid=153&lid=2510&num=50&page=1
    return "https://feed.mix.sina.com.cn/api/roll/get?pageid=153&lid=2510&num=$size&page=$page";
  }

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureSinaRollNewsResult = _getLatestItemNews();

// 上拉添加监听器（并不是滑倒手机屏幕底部就更新数据，而是当前页的数据加载完之后更新下一頁的数据）
    _scrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      print('滑动到了最底部 ---> $currentPage');
      _getMoreItemNews();
    }
  }

  ///下拉刷新
  // 下拉刷新获取最新的数据，也就是第一页的数据
  Future<List<dynamic>> _getLatestItemNews() async {
    acquiredList.clear();

    print("开始获取最新消息...");
    var response = await fetchSinaRollNewsResult(_genUrl(1));

    /// 如果出现 type 'null' is not a subtype of type 'int' in type cast 然后 无法直接打印response，可能就是
    /// model中设置了 required 的属性，实际取得为null。

    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    // print(response.toJson());
    acquiredList.addAll(response.result!.data ?? []);
    print("最新消息已获取完成.acquiredList长度: ${acquiredList.length}");

    return acquiredList;
  }

// 上拉加载更多
  Future _getMoreItemNews() async {
    setState(() {
      isLoading = true;
    });

    print('加载更多  $isLoading');

    // 上拉加载更多，则应该是获取当前页的下一页的数据
    var response = await fetchSinaRollNewsResult(_genUrl(currentPage + 1));
    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    acquiredList.addAll(response.result!.data ?? []);
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
      // 下拉刷新就是加载最新一页的数据
      onRefresh: _getLatestItemNews,
      child: FutureBuilder<List<dynamic>>(
        future: futureSinaRollNewsResult,
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
                        ? NewsItemCardWidget(index: index, data: data[index])
                        : const LoadingMoreWidget();
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
}

/// 构建新闻条目卡片，新闻标题和概要部分直接写，底部區域使用上面个widget。
class NewsItemCardWidget extends StatefulWidget {
  final int index;
  final DataData data;

  const NewsItemCardWidget({Key? key, required this.index, required this.data})
      : super(key: key);

  @override
  State<NewsItemCardWidget> createState() => _NewsItemCardWidgetState();
}

class _NewsItemCardWidgetState extends State<NewsItemCardWidget> {
  @override
  Widget build(BuildContext context) {
    // 单条的新闻数据
    DataData newsItem = widget.data;

    // 返回的时间戳为秒，但DateTime转换时间戳只支持毫秒和微秒，所以*1000。
    // String createTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
    //     DateTime.fromMillisecondsSinceEpoch(int.parse(newsItem.ctime ??
    //             DateTime.now().millisecondsSinceEpoch.toString()) *
    //         1000));

    String modifiedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        DateTime.fromMillisecondsSinceEpoch(int.parse(newsItem.mtime ??
                DateTime.now().millisecondsSinceEpoch.toString()) *
            1000));

    return Container(
      height: 100.sp,
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
              text: TextSpan(
                children: [
                  TextSpan(
                    // 不指定颜色可能默认为白色，看不见，像是没有内容一样(Theme.of()本身返回TextStyle)
                    // style: Theme.of(context).textTheme.bodyText2,
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: sizeHeadline3,
                    ),
                    text: "${widget.index} --- ${newsItem.title}",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        // 如果有直接的url属性，则是非热门话题，直接取得；否则就是热门话题，从关联新闻中取第一个
                        var url =
                            Uri.parse(newsItem.wapurl ?? newsItem.url ?? "");
                        // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                        if (await canLaunchUrl(url)) {
                          await launchUrl(
                            url,
                            mode: LaunchMode.inAppWebView,
                            webViewConfiguration: const WebViewConfiguration(
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
            ),
            // // 标题和摘要之间的空行
            // SizedBox(
            //   height: 6.sp,
            // ),
            // 摘要
            Expanded(
              flex: 1,
              child: Text(
                newsItem.intro ?? "",

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
                style: Theme.of(context).textTheme.bodySmall!.copyWith(
                    letterSpacing: 1.0,
                    fontSize: sizeContent3,
                    color: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .color!
                        .withOpacity(0.8)),
              ),
            ),
            // 底部日期、来源等信息（与readhub中不一样，那个是Text，这个是RichText，占用高度要多些）
            Expanded(
              flex: 1,
              child: Row(
                children: <Widget>[
                  //  // 发布时间
                  // Expanded(
                  //   flex: 1,
                  //   child: Text(
                  //     "发布时间:$createTime",
                  //     textScaleFactor: 1.0,
                  //     maxLines: 1,
                  //     ///浏览器...显示异常
                  //     overflow: PlatformUtil.isWeb
                  //         ? TextOverflow.fade
                  //         : TextOverflow.ellipsis,
                  //     style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  //           fontSize: sizeContent4,
                  //         ),
                  //   ),
                  // ),
                  // 更新时间
                  Expanded(
                    flex: 1,
                    child: RichText(
                      text: TextSpan(
                        text: '更新时间: ',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: sizeContent4,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: modifiedTime,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: sizeContent4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // 来源媒体
                  Expanded(
                    flex: 1,
                    child: RichText(
                      text: TextSpan(
                        text: '来源媒体: ',
                        style: Theme.of(context).textTheme.bodySmall!.copyWith(
                              fontSize: sizeContent4,
                            ),
                        children: <TextSpan>[
                          TextSpan(
                            text: newsItem.media_name ?? '未知来源',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: sizeContent4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
