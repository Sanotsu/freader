// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:freader/utils/platform_util.dart';
import 'package:freader/views/readhub_category/fetch_readhub_api_result.dart';
import 'package:freader/views/readhub_category/readhub_common_widgets.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

/// 特別注意，这里的 ItemsData 类不是readhub_api_topics_result的，而是在 readhub_api_common_result 。
/// 后续应该想办法合二为一。
///
import '../../models/readhub_api_common_result.dart';

/// readhub中除了topics之外，其他指定类型的分类。（结构是一样的，只有url的类型不一样而已，可以复用）
class ReadhubTypedNews extends StatefulWidget {
  // 需要传入新闻类别
  final String newsType;
  const ReadhubTypedNews({Key? key, required this.newsType}) : super(key: key);

  @override
  State<ReadhubTypedNews> createState() => _ReadhubTypedNewsState();
}

class _ReadhubTypedNewsState extends State<ReadhubTypedNews> {
  //每次获取的数据列表要展示的数据
  late Future<List<dynamic>> futureReadhubApiCommonResult;
  // 已经获取到的数据（readhub_api_common_result 中的 ItemsData,新ItemsData的属性全是required，不必判空）
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
    url =
        "https://api.readhub.cn/news/list?size=$size&type=${widget.newsType}&page=$page";
    return url;
  }

  @override
  void initState() {
    super.initState();
    print("--------------${widget.newsType},---${_genUrl(1)}");
    // 初始的时候为第一页开始
    futureReadhubApiCommonResult = _getItemNews();
    currentPage = 1;

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

  ///获取最新消息
  // 下拉刷新，也一直是第一页
  Future<List<dynamic>> _getItemNews() async {
    acquiredList.clear();

    print("开始获取最新消息...");
    var response = await fetchReadhubApiCommonResult(_genUrl(1));

    /// 如果出现 type 'null' is not a subtype of type 'int' in type cast 然后 无法直接打印response，可能就是
    /// model中设置了 required 的属性，实际取得为null。

    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    var temp = response[0].data.items;
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

    // 延迟5秒，看一下加载效果
    await Future.delayed(const Duration(seconds: 5));

    var response = await fetchReadhubApiCommonResult(_genUrl(currentPage));
    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    var temp = response[0].data.items;
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
      onRefresh: _getItemNews,
      child: FutureBuilder<List<dynamic>>(
        future: futureReadhubApiCommonResult,
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
                        // ? _buildItemCard(context, index, data)
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

/// ----------------- 以下两个其实可以直接写在 _ReadhubTypedNewsState 作为私有函数------------------
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
    var createdTime = DateTime.parse(widget.newsItem.createdAt);
    if (createdTime.isUtc) {
      createdTime = createdTime.add(const Duration(hours: 8));
    }

    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          // 发布时间格式化，加上发布的网站名称
          child: Text(
            DateFormat('yyyy-MM-dd HH:mm:ss').format(createdTime) +
                "    " +
                "${widget.newsItem.siteNameDisplay} ",
            textScaleFactor: 1.0,
            maxLines: 1,

            ///浏览器...显示异常
            overflow:
                PlatformUtil.isWeb ? TextOverflow.fade : TextOverflow.ellipsis,
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
          tooltip: 'news agg list',
          child: Icon(
            Icons.link,
            size: 14.sp,
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
    );
  }
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
                    text: "${widget.index} --- ${newsItem.title}",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = newsItem.url;
                        // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                        if (await canLaunch(url)) {
                          await launch(url,
                              forceSafariVC: true,
                              forceWebView: true,
                              enableDomStorage: true,
                              enableJavaScript: true);
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
                newsItem.summary,

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
