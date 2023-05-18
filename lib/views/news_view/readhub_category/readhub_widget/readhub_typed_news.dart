// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/readhub_api_result.dart';
import 'package:freader/models/readhub_api_topic_detail.dart';
import 'package:freader/widgets/global_styles.dart';
import 'package:freader/utils/platform_util.dart';
import 'package:freader/views/news_view/readhub_category/readhub_widget/fetch_readhub_api_result.dart';
import 'package:freader/views/news_view/readhub_category/readhub_widget/readhub_topic_detail_dialog.dart';
import 'package:freader/widgets/common_widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// readhub中除了daily之外，其他指定类型的分类。
class ReadhubTypedNews extends StatefulWidget {
  // 需要传入新闻类别
  final String newsType;
  const ReadhubTypedNews({Key? key, required this.newsType}) : super(key: key);

  @override
  State<ReadhubTypedNews> createState() => _ReadhubTypedNewsState();
}

class _ReadhubTypedNewsState extends State<ReadhubTypedNews> {
  //每次获取的数据列表要展示的数据
  late Future<List<dynamic>> futureReadhubApiResult;
  // 已经获取到的数据
  List<ItemsData> acquiredList = [];
  // 记录当前页面，下拉或者上拉的时候就要更新
  var currentPage = 1;
  //是否正在加载数据
  bool isLoading = false;
  // 每页加载的數量
  var size = 10;
  // 当前请求的api的路径，page和size变化之后，要修改此url去获取新的数据
  late String url;
  //listview的控制器，侦听上拉加载更多数据
  final ScrollController _scrollController = ScrollController();

  // 根据传入的新闻类型，构建对应的请求接口
  String _genUrl(int page) {
    if (widget.newsType == "topics") {
      url = "https://api.readhub.cn/topic/list?page=$page&size=$size";
    } else {
      url =
          "https://api.readhub.cn/news/list?size=$size&type=${widget.newsType}&page=$page";
    }
    return url;
  }

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureReadhubApiResult = _getLatestItemNews();

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
    var response = await fetchReadhubApiCommonResult(_genUrl(1));

    /// 如果出现 type 'null' is not a subtype of type 'int' in type cast 然后 无法直接打印response，可能就是
    /// model中设置了 required 的属性，实际取得为null。

    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    var temp = response[0].data!.items ?? [];

    acquiredList.addAll(temp);
    print("最新消息已获取完成.acquiredList长度: ${acquiredList.length}");

    return acquiredList;
  }

// 上拉加载更多
  Future _getMoreItemNews() async {
    setState(() {
      isLoading = true;
    });

    print('加载更多  $isLoading');

    // 延迟3秒，看一下加载效果
    await Future.delayed(const Duration(seconds: 1));

    // 上拉加载更多，则应该是获取当前页的下一页的数据
    var response = await fetchReadhubApiCommonResult(_genUrl(currentPage + 1));
    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
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
      // 下拉刷新就是加载最新一页的数据
      onRefresh: _getLatestItemNews,
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
                        ? ItemCardWidget(
                            context: context, index: index, data: data)
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

// 因为加了个监听,在组件卸载掉的时候记得移除这个监听
  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
  }
}

/// ----------------- 以下几个widget其实可以直接写在 _ReadhubTypedNewsState 作为私有函数------------------
/// 2022-04-27：目前还未学习到使用class和函数的细致区别
/// 构建新闻条目卡片底部区域，发布时间、发布媒体、一些预留操作按钮
///   需要传入指定新闻信息
class ItemCardBottomAreaWidget extends StatefulWidget {
  final ItemsData newsItem;
  const ItemCardBottomAreaWidget({Key? key, required this.newsItem})
      : super(key: key);

  @override
  State<ItemCardBottomAreaWidget> createState() =>
      _ItemCardBottomAreaWidgetState();
}

class _ItemCardBottomAreaWidgetState extends State<ItemCardBottomAreaWidget> {
  @override
  Widget build(BuildContext context) {
    // 获取创建时间，如果是utc，则加8个小时显示成北京时间
    var createdTime = DateTime.parse(widget.newsItem.createdAt ?? "");
    if (createdTime.isUtc) {
      createdTime = createdTime.add(const Duration(hours: 8));
    }

    /// 如果是热门话题，则可以底部弹出其它媒体报道
    Future<void> showNewsDialog(BuildContext context) async {
      await showModalBottomSheet<int>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Theme.of(context).cardColor,
          builder: (BuildContext context) {
            return ListView.builder(
                itemCount:
                    1, // 点击更多链接是一个新闻一个按钮，但下面的newsAggList有多少，则不定长度，子widget自行生成
                shrinkWrap: true,
                itemBuilder: (context, index) =>
                    buildNewsAggList(context, widget.newsItem));
          });
    }

    /// 如果是热门话题，则可以弹窗显示其新闻细节
    Future<void> showTopicDetailDialog(BuildContext context, topicId) async {
      genUrl() {
        return "https://api.readhub.cn/topic/$topicId";
      }

      print("开始获取详情...${genUrl()}");
      var response = await fetchReadhubTopicDetailResult(genUrl());

      /// 如果出现 type 'null' is not a subtype of type 'int' in type cast 然后 无法直接打印response，可能就是
      /// model中设置了 required 的属性，实际取得为null。
      ReadhubApiTopicDetailData topicDetail = response[0];

      if (!mounted) return;
      await showDialog(
          context: context,
          builder: (BuildContext context) {
            return ReadhubTopicDetailDialog(
              topicDetail: topicDetail,
            );
          });
    }

    /// 已收藏的文章，用于下面图标标星
    // var staredArticleList = ["111", "8fBKiuLOUyn"];

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          // 发布时间格式化，加上发布的网站名称
          child: Text(
            "${DateFormat('yyyy-MM-dd HH:mm:ss').format(createdTime)}   ${widget.newsItem.siteNameDisplay} ",
            textScaleFactor: 1.0,
            maxLines: 1,

            ///浏览器...显示异常
            overflow:
                PlatformUtil.isWeb ? TextOverflow.fade : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  fontSize: sizeContent4,
                ),
          ),
        ),

        /// 都是預留而已
        // // 分享
        // SmallButtonWidget(
        //   onTap: () => {},
        //   tooltip: "share",
        //   child: Icon(
        //     Icons.share,
        //     size: bottomIconButtonSize2,
        //   ),
        // ),
        // // 收藏
        // SmallButtonWidget(
        //   onTap: () => {},
        //   tooltip: "star",
        //   child: staredArticleList.contains(widget.newsItem.uid)
        //       ? Icon(
        //           Icons.star,
        //           size: bottomIconButtonSize2,
        //           color: Colors.lightBlue,
        //         )
        //       : Icon(Icons.star, size: bottomIconButtonSize2),
        // ),
        // 热门话题有更多链接，其他的就没有
        widget.newsItem.newsAggList != null
            ? SmallButtonWidget(
                onTap: () => showNewsDialog(context),
                tooltip: 'news agg list',
                child: Icon(
                  Icons.link,
                  size: bottomIconButtonSize2,
                  color: Colors.lightBlue,
                ),
              )
            : Container(),
        // 查看详情web
        // 热门话题有更多链接，其他的就没有
        widget.newsItem.newsAggList != null
            ? SmallButtonWidget(
                // 路由跳转
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (context) =>
                //           const ReadhubTopicDetailRoute(todo: Todo("zhangsan", "lisi")),
                //     ),
                //   );
                // },
                onTap: () =>
                    showTopicDetailDialog(context, widget.newsItem.uid),
                tooltip: "detail",
                child: Icon(
                  Icons.details,
                  size: bottomIconButtonSize2,
                  color: Colors.lightBlue,
                ),
              )
            : Container(),
      ],
    );
  }
}

/// ItemCard底部显示更多新闻链接
/// 如果是热门话题，则可以点击查看更多的新闻链接。
Widget buildNewsAggList(context, ItemsData newsItem) {
  List<NewsagglistData> newsAggList = newsItem.newsAggList ?? [];

  print(">>>>>>>>>>>>>>>>>>>");

  List<Widget> list = <Widget>[];

  for (var i = 0; i < newsAggList.length; i++) {
    list.add(
        // 橫向排列，title和siteNameDisplay占比为3:1。改为Row，不要direction属性是一样的。
        Flex(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      direction: Axis.horizontal,
      children: [
        Expanded(
          flex: 3,
          child: GestureDetector(
            onTap: () async {
              // 先关闭_showNewsDialog中创建的 ModalBottomSheet
              Navigator.pop(context);
              // 再在应用內打开url
              var url = Uri.parse("${newsAggList[i].url}");
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
            child: SizedBox(
              height: 30.0.sp,
              child: Text(
                "${newsAggList[i].title}",
                softWrap: true,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.lightBlue,
                  fontSize: 14.sp,
                ),
              ),
            ),
          ),
        ),
        // 不加Expanded，不知道Text的宽度，则不会以省略号显示。
        Expanded(
          flex: 1,
          child: SizedBox(
            height: 30.0.sp,
            child: Text(
              "${newsAggList[i].siteNameDisplay}",
              softWrap: true,
              textAlign: TextAlign.left,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    ));
  }

// SizedBox指定高度，SingleChildScrollView里面的数据高度大于此，则可以上下滚动查看
// 不指定，则可能默认是整个屏幕高度。
  return SizedBox(
    // height: 200.sp,
    child: SingleChildScrollView(
      padding: EdgeInsets.all(16.0.sp),
      child: Center(
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: list),
      ),
    ),
  );
}

/// 构建新闻条目卡片，新闻标题和概要部分直接写，底部區域使用上面个widget。
class ItemCardWidget extends StatefulWidget {
  // 注意：这是上层widget得context，不要和子widget的context搞混了。
  final BuildContext context;
  final int index;
  final List<dynamic> data;

  const ItemCardWidget(
      {Key? key,
      required this.context,
      required this.index,
      required this.data})
      : super(key: key);

  @override
  State<ItemCardWidget> createState() => _ItemCardWidgetState();
}

class _ItemCardWidgetState extends State<ItemCardWidget> {
  @override
  Widget build(BuildContext context) {
    ItemsData newsItem = widget.data[widget.index];
    return Container(
      height: 100,
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
                    style: TextStyle(
                      color: Colors.lightBlue,
                      fontSize: sizeHeadline3,
                    ),
                    text: "${widget.index} --- ${newsItem.title}",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        // 如果有直接的url属性，则是非热门话题，直接取得；否则就是热门话题，从关联新闻中取第一个
                        var url = Uri.parse(
                            newsItem.url ?? "${newsItem.newsAggList![0].url}");
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
            // 发布时间，其他icon等新闻条目底部区域。
            ItemCardBottomAreaWidget(
              newsItem: newsItem,
            ),
          ],
        ),
      ),
    );
  }
}
