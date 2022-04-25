// ignore_for_file: avoid_print

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:freader/models/readhub_api_result.dart';
import 'package:freader/views/readhub_category/fetch_readhub_api_result.dart';
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

// 打开url链接
  Future<void> _launchInWebViewOrVC(String url) async {
    if (await canLaunch(url)) {
      await launch(
        url,
        // 这些配置看实际需求，有个url看起来能用
        forceSafariVC: true,
        forceWebView: true,
        headers: <String, String>{'my_header_key': 'my_header_value'},
      );
    } else {
      throw 'Could not launch $url';
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
    print("最新消息已获取完成.");

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
    return Container(
      height: 80,
      color: Colors.white,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$index ---    ${data![index].title}"),
            RichText(
              text: TextSpan(children: [
                TextSpan(
                    // 不指定颜色可能默认为白色，看不见，像是没有内容一样
                    style: Theme.of(context).textTheme.bodyText1,
                    text: "${data[index].title}",
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        var url = "${data[index].newsAggList![0].url}";
                        if (await canLaunch(url)) {
                          await launch(url);
                        } else {
                          throw 'Could not launch $url';
                        }
                      }),
              ]),
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                _launched =
                    _launchInWebViewOrVC("${data[index].newsAggList![0].url}");
              }),
              child: const Text('Launch in app'),
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
        padding: const EdgeInsets.all(10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const <Widget>[
            Text(
              '加载中...',
              style: TextStyle(fontSize: 16.0),
            ),
            CircularProgressIndicator(
              strokeWidth: 1.0,
            )
          ],
        ),
      ),
    );
  }
}
