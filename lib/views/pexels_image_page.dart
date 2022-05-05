// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:freader/models/pexels_api_images_result.dart';
import 'package:freader/views/pexels_image_widget/fetch_pexels_api_result.dart';
import 'package:freader/views/readhub_category/readhub_common_widgets.dart';

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

  // 定义一个子widget FormTestRoute 使用的全局key
  final _childKey = GlobalKey<_FormTestRouteState>();

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
  // 下拉刷新获取最新的数据，也就是第一页的数据
  Future<List<PhotosData>> _getLatestItemNews() async {
    print("，开始获取json...");
    var response = await getLocalPexelsApiImageJson(1);

    /// 如果出现 type 'null' is not a subtype of type 'int' in type cast 然后 无法直接打印response，可能就是
    /// model中设置了 required 的属性，实际取得为null。

    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    var temp = response ?? [];

    print(temp.length);
    print("----------");
    acquiredList.addAll(temp);

    return acquiredList;
  }

// 上拉加载更多
  Future _getMoreItemNews() async {
    setState(() {
      isLoading = true;
    });

    print('加载更多  $isLoading');

    // 延迟3秒，看一下加载效果
    await Future.delayed(const Duration(seconds: 3));

    // 上拉加载更多，则应该是获取当前页的下一页的数据
    var response = await getLocalPexelsApiImageJson(currentPage + 1);
    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    var temp = response ?? [];
    acquiredList.addAll(temp);
    // 获取完之后，更新當前頁数据
    currentPage++;

    setState(() {
      isLoading = false;
    });

    print('加载完成  $isLoading');
  }

  /// 关键字查询图片
  Future _getQueryItems(String photoKeyWord) async {
    setState(() {
      isLoading = true;
      acquiredList.clear();
    });

    print('加载更多  $isLoading , 关键字 $photoKeyWord');

    // 延迟3秒，看一下加载效果
    await Future.delayed(const Duration(seconds: 3));

    // 上拉加载更多，则应该是获取当前页的下一页的数据
    var response = await getLocalPexelsApiImageJson(4);
    // addAll()里面必须也是一个`List<>`，而不是一个`List<>?`。
    var temp = response ?? [];

    setState(() {
      isLoading = false;
      acquiredList.addAll(temp);
      // 获取完之后，更新當前頁数据
      currentPage++;
      print('加载完成  $isLoading');
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
              // 如果正常获取数据，但数据为空
              return const Center(
                // child: Text("empty or null data"),
                child: Text("loading..."),
              );
            }
          }

          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );

    /// 搜素查询行
    Widget _buildQueryRow() {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: 20.sp,
            width: 0.7.sw,
            child: TextField(
              controller: _queryTextController, // 控制器
              focusNode: _keyWordFocus, // 輸入框焦点
              decoration: InputDecoration(
                prefixIcon: Icon(
                  Icons.search,
                  size: 14.sp,
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(5.0.sp),
            child: SizedBox(
              width: 0.2.sw, // <-- Your width
              height: 20.sp, // <-- Your height
              child: ElevatedButton(
                child: Text(
                  "查询",
                  style: TextStyle(fontSize: 10.sp),
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

    return Column(
      children: <Widget>[
        _buildQueryRow(),
        // FormTestRoute(key: _childKey, getLatest: _getQueryItems),
        Expanded(child: fb),
      ],
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

// 构建图片列表 GridView（使用中）
  Widget _buildGridView(data) {
    // var size = MediaQuery.of(context).size;

    /*24 is for notification bar on Android*/
    // final double itemHeight = (size.height - kToolbarHeight - 24) / 3;
    // final double itemWidth = size.width / 3;

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

/// 构建单个图片Card 第二种
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
    var smallSrc = pd.src?.small ?? "";

    var pdwidth = pd.width ?? 130.sp;
    var pdheight = pd.height ?? 145.sp;

    print(pdwidth);
    print(pdheight);
    print(pdwidth / pdheight);
    print("${pdheight / (pdwidth / 130)}=====================");

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
                  builder: (context) => PhotoDetailPage(photoData: pd),
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

/// 点击指定图片跳转的详情页
class PhotoDetailPage extends StatelessWidget {
  final PhotosData photoData;
  const PhotoDetailPage({Key? key, required this.photoData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var src = photoData.src?.medium;

    return Scaffold(
      appBar: AppBar(
        title: const Text('照片详情 ✌️'),
      ),
      body: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: SizedBox(
              width: double.infinity,
              child: src != ""
                  ? Image(
                      image: NetworkImage("$src"),
                    )
                  : const Icon(Icons.no_accounts),
            ),
          ),
          Text(
            "描述： ${photoData.alt}",
            maxLines: 3,
            style: TextStyle(
              fontSize: 14.sp,
              height: 1.2,
            ),
          ),
          Container(
            margin: EdgeInsets.all(5.0.sp),
            child: Text(
              "作者：${photoData.photographer}",
              style: TextStyle(fontSize: 14.sp),
            ),
          ),
          // 预留的照片详情的操作按鈕
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "share",
                child: Icon(
                  Icons.share,
                  size: 14.sp,
                ),
              ),
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "star",
                child: Icon(
                  Icons.star,
                  size: 14.sp,
                ),
              ),
              SmallButtonWidget(
                onTap: () => {},
                tooltip: "download",
                child: Icon(
                  Icons.download,
                  size: 14.sp,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}

/// form表单输入查询关键字，点击确认提交后查询
class FormTestRoute extends StatefulWidget {
  final Function getLatest;

  const FormTestRoute({Key? key, required this.getLatest}) : super(key: key);

  @override
  _FormTestRouteState createState() => _FormTestRouteState();
}

class _FormTestRouteState extends State<FormTestRoute> {
  final TextEditingController _unameController = TextEditingController();

  late String textValue = "";

  @override
  Widget build(BuildContext context) {
    return Form(
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Row(
        children: <Widget>[
          Expanded(
            child: SizedBox(
              width: 100.sp,
              child: TextFormField(
                autofocus: true,
                controller: _unameController,
                decoration: const InputDecoration(
                  icon: Icon(Icons.person),
                ),
              ),
            ),
          ),

          // 登录按钮
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(left: 8.0.sp),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: ElevatedButton(
                      child: Padding(
                        padding: EdgeInsets.all(1.0.sp),
                        child: const Text("查询"),
                      ),
                      onPressed: () {
                        print("点击查询   ${_unameController.text}");
                        setState(() {
                          textValue = _unameController.text;
                        });
                        widget.getLatest();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
