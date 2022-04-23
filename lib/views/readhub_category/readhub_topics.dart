// ignore_for_file: avoid_print

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
  late Future<List<ReadhubApiResult>> futureReadhubApiResult; //每次获取的数据列表要展示的数据
  List<ItemsData> acquiredList = []; // 已经获取到的数据
  var currentPage = 1; // 记录当前页面，下拉或者上拉的时候就要更新
  bool isLoading = false; //是否正在加载数据
  var size = 10; // 每页加载的數量

  late String url; // 当前请求的api的路径，page和size变化之后，要修改此url去获取新的数据

  // ignore: unused_field
  Future<void>? _launched;

  // final ScrollController _scrollController = ScrollController(); //listview的控制器

  String _genUrl(int page) {
    url = "https://api.readhub.cn/topic/list?page=$page&size=$size";
    return url;
  }

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futureReadhubApiResult = fetchReadhubApiResult(_genUrl(1));
    currentPage = 1;

// 上拉添加监听器（并不是滑倒手机屏幕底部就更新数据，而是当前页的数据加载完之后更新下一頁的数据）
    // _scrollController.addListener(() {
    //   if (_scrollController.position.pixels ==
    //       _scrollController.position.maxScrollExtent) {
    //     print('滑动到了最底部 ---> $currentPage');
    //     _getMore();
    //   }
    // });
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

// 下拉刷新，也一直是第一页
  Future<void> _onRefresh() async {
    print('refresh');
    setState(() {
      futureReadhubApiResult = fetchReadhubApiResult(_genUrl(1));
    });
  }

// 上拉加载更多
  Future _getMore() async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      print('加载更多');
      setState(() {
        futureReadhubApiResult = fetchReadhubApiResult(_genUrl(currentPage));
        // 获取完之后，更新當前頁数据
        currentPage++;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<ReadhubApiResult>>(
        future: futureReadhubApiResult,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            // 这里snapshot是顶层的data，要构建列表的是其items属性
            List<ItemsData>? data = snapshot.data![0].data!.items;
            return RefreshIndicator(
              onRefresh: _onRefresh,
              child: ListView.builder(
                itemCount: data!.length,
                itemBuilder: (BuildContext context, int index) {
                  print("当前index $index,data.length的长度 ${data.length}");

                  // 如果当前的索引，小于每页的size，则正常渲染每条数据
                  if (index < data.length) {
                    return _buildItemCard(context, index, data);
                  }
                  // 否则加载新的数据
                  return _getMoreWidget();
                },
                // controller: _scrollController,
              ),
            );
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }

  Widget _buildItemCard(
      BuildContext context, int index, List<ItemsData>? data) {
    return Container(
      height: 80,
      color: Colors.white,
      child: Card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("$index ---    ${data![index].title}"),
            // RichText(
            //   text: TextSpan(children: [
            //     TextSpan(
            //         // 不指定颜色可能默认为白色，看不见，像是没有内容一样
            //         style: Theme.of(context).textTheme.bodyText1,
            //         text: "${data![index].title}",
            //         recognizer: TapGestureRecognizer()
            //           ..onTap = () async {
            //             var url = "${data[index].newsAggList![0].url}";
            //             if (await canLaunch(url)) {
            //               await launch(url);
            //             } else {
            //               throw 'Could not launch $url';
            //             }
            //           }),
            //   ]),
            // ),
            // ElevatedButton(
            //   onPressed: () => setState(() {
            //     _launched =
            //         _launchInWebViewOrVC("${data[index].newsAggList![0].url}");
            //   }),
            //   child: const Text('Launch in app'),
            // ),
          ],
        ),
      ),
    );
  }

  /// 加载更多时显示的组件,给用户提示
  Widget _getMoreWidget() {
    _getMore();

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
