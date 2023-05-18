// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:freader/widgets/global_styles.dart';
import 'package:freader/views/image_view/pexels_category/pexels_image_widget/fetch_pexels_api_result.dart';
import 'package:freader/views/image_view/pexels_category/pexels_image_widget/pexels_image_detail_page.dart';

import 'package:freader/widgets/common_widgets.dart';

/// 2022-05-05
/// 为了简单方便，pexels图片，默认进来就只加载80张编辑精选
/// 输入框有值，则为条件查询，上拉下拉加载輸入框关键字的内容。
/// 輸入框没有值，则查询编辑精选，上拉下来查询编辑精选图片。

class PexelsImagePage extends StatefulWidget {
  const PexelsImagePage({Key? key}) : super(key: key);

  @override
  State<PexelsImagePage> createState() => _PexelsImagePageState();
}

class _PexelsImagePageState extends State<PexelsImagePage> {
  late Future<List<PhotosData>> futurePhotos;
  // 已经获取到的数据
  List<PhotosData> acquiredList = [];
  // 记录当前页面，下拉或者上拉的时候就要更新
  var currentPage = 1;
  //是否正在加载数据
  bool isLoading = false;
  //listview的控制器，侦听上拉加载更多数据
  final ScrollController _scrollController = ScrollController();
  // 文字輸入框的控制器
  final _queryTextController = TextEditingController();
// 关键字輸入框的焦点
  final FocusNode _keyWordFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    // 初始的时候为第一页开始
    futurePhotos = _getLatestItemNews();
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
  ///根据查询搜索框是否有内容来区分默认精选还是查询，但都是第一页
  Future<List<PhotosData>> _getLatestItemNews() async {
    // 清空已有数据，重置页码
    acquiredList.clear();
    currentPage = 1;

    print("开始获取pexel最新图片...");
    List<PhotosData> response;
    if (_queryTextController.text != "") {
      var queryParams =
          "?page=$currentPage&per_page=80&query=${_queryTextController.text}";
      response = await fetchPexelsApiImageQueryResult(queryParams);
    } else {
      response = await fetchPexelsApiImageCuratedResult(currentPage);
    }

    print("---------- 获取的最新图片數量 ${response.length}");
    acquiredList.addAll(response);

    return acquiredList;
  }

  /// 上拉加载更多
  /// 根据查询搜索框是否有内容来区分默认精选还是查询，但都是第一页
  Future _getMoreItemNews() async {
    setState(() {
      isLoading = true;
    });

    print('开始加载更多, loading is $isLoading');

    // 上拉加载更多，则应该是获取当前页的下一页的数据
    List<PhotosData> response;
    if (_queryTextController.text != "") {
      var queryParams =
          "?page=${currentPage + 1}&per_page=80&query=${_queryTextController.text}";
      response = await fetchPexelsApiImageQueryResult(queryParams);
    } else {
      response = await fetchPexelsApiImageCuratedResult(currentPage + 1);
    }

    setState(() {
      acquiredList.addAll(response);
      // 获取完之后，更新當前頁数据
      currentPage++;
      isLoading = false;
      print('加载完成  $isLoading');
    });
  }

  /// 关键字查询图片
  /// 关键字查询则会清空现在已有的列表，重置页码为1
  Future _getQueryItems(String photoKeyWord) async {
    setState(() {
      isLoading = true;
      acquiredList.clear();
      currentPage = 1;
    });

    print('开始关键字查询, loading is: $isLoading , 关键字为: $photoKeyWord');

    // 上拉加载更多，则应该是获取当前页的下一页的数据
    List<PhotosData> response;
    if (_queryTextController.text != "") {
      var queryParams =
          "?page=$currentPage&per_page=80&query=${_queryTextController.text}";
      response = await fetchPexelsApiImageQueryResult(queryParams);
    } else {
      response = await fetchPexelsApiImageCuratedResult(currentPage);
    }

    setState(() {
      isLoading = false;
      acquiredList.addAll(response);
      // 获取完之后，更新當前頁数据
      currentPage++;
      print('----------关键字查询加载完成  $isLoading,获取的关键字查询图片數量 ${response.length}"');
    });
  }

  @override
  Widget build(BuildContext context) {
    var fb = RefreshIndicator(
      // 下拉刷新就是加载最新一页的数据
      onRefresh: _getLatestItemNews,
      child: FutureBuilder<List<PhotosData>>(
        future: futurePhotos,
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
            print("snapshot.data!.length");
            // 如果正常获取数据，且数据不为空
            if (snapshot.hasData &&
                snapshot.data != null &&
                snapshot.data!.isNotEmpty) {
              // 这里snapshot.data就是acquiredList
              List? data = snapshot.data;
              return _buildGridView(data);
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
    );

    /// 搜素查询行
    Widget buildQueryRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: 40.sp,
            width: 0.7.sw,
            child: TextField(
              controller: _queryTextController, // 控制器
              focusNode: _keyWordFocus, // 輸入框焦点
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: bottomIconButtonSize1,
                ),
              ),
              style: TextStyle(
                fontSize: sizeContent2,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0.sp),
            child: SizedBox(
              width: 0.2.sw,
              height: 30.sp,
              child: ElevatedButton(
                child: Text(
                  "查询",
                  style: TextStyle(fontSize: sizeContent3),
                ),
                onPressed: () {
                  print("_queryTextController ${_queryTextController.text}");
                  _getQueryItems(_queryTextController.text);
                  // 点击查询之后，清空輸入框文字，并失去焦点
                  // _queryTextController.text = ""; // 如果考虑用户要看查询内容，则不清空，组件銷毀时会清空。
                  _keyWordFocus.unfocus();
                },
              ),
            ),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Pexels"),
        // 2022-05-06 后续可参看 lib\_demos\search_on_app_bar.dart 做readhub的新闻查询。
        // actions: <Widget>[
        //   IconButton(
        //     iconSize: 20,
        //     icon: const Icon(
        //       Icons.search,
        //       semanticLabel: 'search', // icon的语义标签。
        //     ),
        //     onPressed: () {},
        //   ),
        // ],
      ),
      body: Column(
        children: <Widget>[
          buildQueryRow(),
          Expanded(child: fb),
        ],
      ),
    );
  }

// 因为加了个监听,在组件卸载掉的时候记得移除这个监听
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    super.dispose();
    _scrollController.dispose();
    _queryTextController.dispose();
  }

// 构建图片列表 GridView
  Widget _buildGridView(data) {
    return Center(
      child: GridView.builder(
        physics: const ScrollPhysics(),
        itemCount: data!.length + 1,
        // 定义网格相关样式
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          // 定义列
          crossAxisCount: 3,
          // 横向间隙
          mainAxisSpacing: 10.0.sp,
          // grid每个child在主轴方向的长度（默认180.sp）。如果为null，使用childAspectRatio代替。
          mainAxisExtent: 180.sp,
          // 纵向间隙
          crossAxisSpacing: 10.0.sp,
          // 每个 child 的横轴与主轴范围的比率。
          // childAspectRatio: (itemWidth / itemHeight),
        ),
        itemBuilder: (BuildContext context, int index) {
          print("当前 photo index $index, 已获取的 photo 数据數量:  ${data.length}");
          return index < data.length
              ? PhotoCardWidget(context: context, index: index, data: data)
              : const LoadingMoreWidget();
        },
        controller: _scrollController,
      ),
    );
  }
}

/// 构建单个图片Card
class PhotoCardWidget extends StatefulWidget {
  // 注意：这是上层widget得context，不要和子widget的context搞混了。
  final BuildContext context;
  final int index;
  final List<dynamic> data;

  const PhotoCardWidget(
      {Key? key,
      required this.context,
      required this.index,
      required this.data})
      : super(key: key);

  @override
  State<PhotoCardWidget> createState() => _PhotoCardWidgetState();
}

class _PhotoCardWidgetState extends State<PhotoCardWidget> {
  @override
  Widget build(BuildContext context) {
    PhotosData pd = widget.data[widget.index];
    // 首页预览用小图片地址，详情页用中图片地址
    var smallSrc = pd.src?.small ?? "";

    // 如果获取的图片没有大小，则默认为130*145.sp
    var pdwidth = pd.width ?? 130.sp;
    var pdheight = pd.height ?? 145.sp;

    final imageWidget = AspectRatio(
      aspectRatio: pdwidth / pdheight,
      child: CachedNetworkImage(
        imageUrl: smallSrc,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: imageProvider,
              fit: BoxFit.cover,
              // 图片颜色过滤
              // colorFilter:
              //     const ColorFilter.mode(Colors.red, BlendMode.colorBurn),
            ),
          ),
        ),
        // placeholder: (context, url) => const CircularProgressIndicator(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );

    /// card的高度，就是在GridView.builder中设置的主轴长度
    /// (2022-05-05 GestureDetector会占用多少不清楚，图片和文字为145+30，card的父級设定180吧)
    /// 130和 145 为预设的图片显示最高宽度 和 高度
    var smallPhtotHeight = (pdheight / (pdwidth / 130)).sp;
    var smallPhotoWidth = (pdwidth / (pdheight / 145)).sp;

    return Card(
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PexelsImageDetailPage(photoData: pd),
                ),
              );
            },
            child: SizedBox(
              /// 预览图使用small的size，但只有固定宽度130，则对应比例的高度为: pdheight / (pdwidth / 130)
              /// 但可能出现高度大于预设高度，那就需要根据高度调整宽度
              width: smallPhtotHeight < 145 ? 130.sp : smallPhotoWidth,
              height: smallPhtotHeight < 145 ? smallPhtotHeight : 145.sp,
              child: imageWidget,
            ),
          ),
          // pading 预计占用30.sp，用于显示名称和按钮，2行。
          Padding(
            padding: EdgeInsets.fromLTRB(5.sp, 4.sp, 5.sp, 2.3.sp),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  "description: ${pd.alt}",
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 6.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 3.sp),
                Text(
                  'photographer: ${pd.photographer}',
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 6.sp,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
