// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/utils/sqlite_helper.dart';
import 'package:freader/models/app_embedded/txt_state.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:page_view_indicators/linear_progress_page_indicator.dart';

class TxtScreenPageView extends StatefulWidget {
  // 如果有阅读记录，则获取该记录继续读；如果没读过，通过txtid获取第一章节，开始读
  // 真实调用时，两个只能传一个，有了txtId，就不能传userTxtState，否则会出问题
  final UserTxtState? userTxtState;
  final String? txtId;

  const TxtScreenPageView({Key? key, this.userTxtState, this.txtId})
      : super(key: key);

  @override
  State<TxtScreenPageView> createState() => _TxtScreenPageViewState();
}

class _TxtScreenPageViewState extends State<TxtScreenPageView> {
  /// 2022-05-30 此处整体流程如下
  /// 1 传入当前txt的用户阅读进度，通过 txtId 和 chapterId，获取到当前小说章节的内容
  ///     如果没有阅读记录，则是从第一章开始
  /// 2 读取内容后，按照给定的字体大小，构造分页和每页内容
  /// 3 跳转到指定页面
  /// 4 按照手势前后翻页（暂不考虑指定页码跳转）
  /// 5 退出阅读页面时，保存新的已读页码
  ///
  /// 语法：
  ///     foo?.bar   --> 如果 foo 为 null 则返回 null ，否则返回 bar
  ///     foo!.bar   --> 如果 foo 为 null，则抛出运行时异常
  ///     表达式 1 ?? 表达式 2   -->  如果表达式 1 为非 null 则返回其值，否则执行表达式 2 并返回其值

  final DatabaseHelper _databaseHelper = DatabaseHelper();
  var uuid = const Uuid();

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

// 不管是第一次阅读还是继续阅读记录，都处理获取其txt编号和当前章节编号，以便后续处理
  var currentTxtId = "";
  var currentChapterId = "";
  // 当前使用的字体大小（存进度也需要）
  double currentTxtFontSize = 16.sp;
  // 当前章节读到的页数（存进度是需要）
  int currentPage = 0;

// 当前的阅读进度编号(currentUserTxtStateId)
  var currentUtsId = "";
  // 当前txt的所有章节标题内容（作为书签）
  List<TxtState> txtChapterList = [];

  // txt文本的全部內容
  var txtFullContent = "";
  // 章节的总数量
  int textLength = 0;
  // txt名称
  var appTitle = "";
  var appSubTitle = "";

  // 是否在加载文件中
  var txtLoading = false;

  // 底下进度条的当前进度
  final _currentPageNotifier = ValueNotifier<int>(0);

// 通过txt编号和章节编号查询对应章节内容
  getChapterDataByChapterId(String txtId, String currentChapterId) async {
    setState(() {
      txtLoading = true;

      // 一旦有切换章节，那当前章节已读页码也得重置到第一页
      currentPage = 0;
      _currentPageNotifier.value = 0;
    });

    List<TxtState> chapterContentList;

    /// 2 有传入阅读进度的处理
    // 指定txt的当前章节，应该只有一条数据了
    chapterContentList = await _databaseHelper.queryTxtStateByIds(
      txtId,
      currentChapterId,
    );

    setState(() {
      // 如果指定编号查询能找到内容，则更新，否则不作为
      if (chapterContentList.isNotEmpty) {
        txtFullContent = chapterContentList[0].chapterContent;
        textLength = chapterContentList[0].chapterContentLength;
        appTitle = chapterContentList[0].txtName;
        appSubTitle = chapterContentList[0].chapterName;
      }
      txtLoading = false;
    });
  }

  // 组件初始化时，根据传入的阅读记录或者txt编号加载章节内容
  loadCurrentChapterData() async {
    /// 1 没有传入阅读记录的处理(新开始读的)
    //  查询第一章节开始
    // 2022-06-04 因为chapterId改为了从1开始的自增，所以不管是首次阅读还是继续阅读，都可以使用同一个db查询操作
    currentTxtId = widget.txtId ?? (widget.userTxtState)?.txtId ?? "";
    currentChapterId = (widget.userTxtState)?.currentChapterId ?? "1";

    await getChapterDataByChapterId(currentTxtId, currentChapterId);

    /// 从阅读记录中获取相关进度信息
    // 阅读记录编号
    currentUtsId = (widget.userTxtState)?.userTxTStateId ?? "";
    // 字体大小
    var temp = double.parse(widget.userTxtState?.currentTxtFontSize ?? "0");
    if (temp != 0.0) {
      setState(() {
        currentTxtFontSize = temp;
      });
    }
    // 当前章节已读的页数,并跳转
    var tempPageNum =
        int.parse(widget.userTxtState?.currentChapterPageNumber ?? "0");
    if (tempPageNum != 0) {
      currentPage = tempPageNum;
    }

    // 查询当前txt的内容，用作书签显示
    var list = await _databaseHelper.queryFirstTxtStateByTxtId(currentTxtId);
    setState(() {
      txtChapterList = list;
    });
  }

  @override
  void initState() {
    print("================前");
    print(widget.txtId);
    print(widget.userTxtState);
    print("================后");

    loadCurrentChapterData();
    super.initState();
  }

// 保存阅读进度，在返回前要更新
  saveReadProgress() async {
    // UserTxtState 需要的栏位
    //txtId,currentChapterId,currentChapterPageNumber,currentTxtFontSize,totalReadProgress,lastReadDatetime,

    var lastReadDatetime = DateFormat('yyyy-MM-dd HH:mm:ss').format(
        (DateTime.now().toLocal()).isUtc
            ? DateTime.now()
            : DateTime.now().add(const Duration(hours: 8)));

    var totalReadProgress = int.parse(currentChapterId) / 120;

    // 如果没有读过，就是新增阅读记录。有读过，就是修改
    var uts = UserTxtState(
        txtId: currentTxtId,
        currentChapterId: currentChapterId,
        currentTxtFontSize: currentTxtFontSize.toString(),
        currentChapterPageNumber: currentPage.toString(),
        lastReadDatetime: lastReadDatetime,
        totalReadProgress: totalReadProgress.toString(),
        userTxTStateId: currentUtsId != "" ? currentUtsId : uuid.v1());
    if (currentUtsId != "") {
      _databaseHelper.updateUserTxtState(uts);
    } else {
      _databaseHelper.insertUserTxtState(uts);
    }
  }

  @override
  Widget build(BuildContext context) {
    // 获取屏幕的宽高(sp)
    var deviceData = MediaQuery.of(context);
    var deviceHeight = deviceData.size.height; // 或者 ScreenUtil().screenWidth
    var deviceWidth = deviceData.size.width; // 或者 ScreenUtil().screenHeight

    // print("屏幕尺寸1: ${ScreenUtil().screenWidth} ${ScreenUtil().screenHeight}");
    // print("屏幕尺寸2: ${deviceData.size.width} ${deviceData.size.height}");

    // txt显示的高度剩余 appbar80 buttom44 进度条5
    // WillPopScope下到显示文字的Text中的间隔边框约为 30*26(宽*高)，如果还有虚拟按钮的高度,默认每页2行空白行
    var noUseHeight = (80 + 45 + 5 + 30).sp +
        ScreenUtil().bottomBarHeight +
        currentTxtFontSize * 2;
    var noUseWidth = 30.sp;

    var txtHeight = deviceHeight - noUseHeight;
    var txtWitdh = deviceWidth - noUseWidth; // 各种组件预估侵占的宽度为60
    // 设备可用来显示文字的面积大小(默认假设每页有2行空白行)
    var deviceDimension = txtHeight * txtWitdh;

    //  计算每页大概多少字
    //  每个字符的估计尺寸：textSize * (textSize * 0.8), 文本大小的宽度估计尺寸是其高度的80%。中文是英文的2倍？
    var perCharSize = currentTxtFontSize * 2 * (currentTxtFontSize * 0.8);
    var pageCharLimit = (deviceDimension / perCharSize).round();

    /// 计算总共大概会有多少页 （总字数/每页字数）向上取整。
    var pageCount = (textLength / pageCharLimit).ceil();

    // print("""长度、面积单位sp:
    //     原始设备高度*宽度 $deviceHeight * $deviceWidth
    //     文本显示高度*宽度 $txtHeight * $txtWitdh 显示总面积:$deviceDimension
    //     当前章节:$currentChapterId 章节总字数:$textLength
    //     当前字体大小:$currentTxtFontSize 每个字占面积:$perCharSize
    //     每页文字数量:$pageCharLimit 该章共多少页:$pageCount 当前页:$currentPage
    //     """);

    /// 2022-05-31 以上这些显示面积的计算都不准确，
    /// 因为空白行数不定、字体大小不定、一页高度并不一定总能显示正常行高、标点和文字占面积不一样，段头段位也有空白
    /// 所以下面这里直接使用真实预估的面积直接计算每页显示文字数量（小米6）
/*
    var temp = ((525.sp * 380.sp) /
        (currentTxtFontSize * (currentTxtFontSize) * 0.9 * 2));

    var pageCharLimit = temp.round();
    var pageCount = (textLength / pageCharLimit).ceil();

    print("当前显示区域面积：$temp  当前字体大小：$currentTxtFontSize 每页文字数量：$pageCharLimit");
    print("当前章节：$currentChapterId  一该章共多少页：$pageCount 当前页：$currentPage ");
*/
    List<String> pageText = [];
    var index = 0;
    var startStrIndex = 0;
    var endStrIndex = pageCharLimit;
    while (index < pageCount) {
      /// Update the last index to the Document Text length
      if (index == pageCount - 1) endStrIndex = textLength;

      /// Add String on List<String>
      pageText.add(txtFullContent.substring(startStrIndex, endStrIndex));

      /// Update index of Document Text String to be added on [pageText]
      if (index < pageCount) {
        startStrIndex = endStrIndex;
        endStrIndex += pageCharLimit;
      }
      index++;
    }

    // 绑定pageview的控制器，以便能初始化到指定页码
    PageController pageController = PageController(
      initialPage: currentPage,
      viewportFraction: 1,
      keepPage: true,
    );

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              appTitle,
            ),
            Visibility(
              visible: true,
              child: Text(
                appSubTitle,
                style: TextStyle(
                  fontSize: 12.0.sp,
                ),
              ),
            ),
          ],
        ),
      ),
      drawer: _buildBookmarkDrawer(txtChapterList, pageController),
      body: WillPopScope(
        onWillPop: () async {
          // 点击appbar返回按钮或者返回键时，先保持已读的进度
          await saveReadProgress();
          if (mounted) {
            Navigator.pop(context);
            // Navigator.pop(context, "data you want return");
          }
          return false;
        },
        child: txtLoading
            ? buildLoadingWidget()
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Expanded(
                    child: PageView.builder(
                      itemCount: pageCount,
                      itemBuilder: (_, index) {
                        return Card(
                          child: Container(
                            padding: EdgeInsets.all(10.0.sp),
                            child: Text(
                              pageText[index],
                              style: TextStyle(fontSize: currentTxtFontSize),
                            ),
                          ),
                        );
                      },
                      onPageChanged: _onPageViewChange,
                      controller: pageController,
                    ),
                  ),
                  _buildLinearProgressIndicator(pageCount),
                ],
              ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context, pageController),
    );
  }

// pageview当前页码（页码是从0开始的）
  _onPageViewChange(int page) {
    print("Current Page: $page");
    setState(() {
      currentPage = page;
      _currentPageNotifier.value = page;
    });
  }

// 底下章节页码进度条
  _buildLinearProgressIndicator(totalPage) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) =>
          LinearProgressPageIndicator(
        itemCount: totalPage,
        currentPageNotifier: _currentPageNotifier,
        progressColor: Colors.green,
        width: constraints.maxWidth,
        height: 4.sp,
      ),
    );
  }

// 下方的功能按钮
  Widget _buildBottomNavigationBar(
    BuildContext ctx,
    PageController pageController,
  ) {
    return BottomAppBar(
      color: Colors.lightBlue,
      child: SizedBox(
        height: 40.sp,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // 书签
            //  通过调用上层Scaffold的key，去打开drawer，以显示书签
            IconButton(
              icon: Icon(
                Icons.bookmark,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            ),
            // 放大
            IconButton(
              icon: Icon(
                Icons.zoom_in,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () {
                // 放大字体(但有最大值)
                if (currentTxtFontSize <= 30) {
                  currentTxtFontSize += 4;
                }
                getChapterDataByChapterId(currentTxtId, currentChapterId);
                //新章节，都是到新章节的第一页
                pageController.jumpToPage(0);
              },
            ),
            // 縮小
            IconButton(
              icon: Icon(
                Icons.zoom_out,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () {
                // 缩小字体（但有最小值）
                if (currentTxtFontSize >= 16) {
                  currentTxtFontSize -= 4;
                }
                getChapterDataByChapterId(currentTxtId, currentChapterId);
                //新章节，都是到新章节的第一页
                pageController.jumpToPage(0);
              },
            ),
            // 切换方向

            // 上一章
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_left,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () {
                // 点击上一章，则修改当前章节编号，并进行查询(有最小值)
                if (int.parse(currentChapterId) > 1) {
                  currentChapterId =
                      (int.parse(currentChapterId) - 1).toString();
                  getChapterDataByChapterId(currentTxtId, currentChapterId);
                  //新章节，都是到新章节的第一页
                  pageController.jumpToPage(0);
                }
              },
            ),
            // 下一章
            IconButton(
              icon: Icon(
                Icons.keyboard_arrow_right,
                color: Colors.white,
                size: 20.sp,
              ),
              onPressed: () {
                // 点击下一章，则修改当前章节编号，并进行查询(有最大值，但西游记只有100回)
                if (int.parse(currentChapterId) < 120) {
                  currentChapterId =
                      (int.parse(currentChapterId) + 1).toString();
                  getChapterDataByChapterId(currentTxtId, currentChapterId);
                  //新章节，都是到新章节的第一页
                  pageController.jumpToPage(0);
                }
              },
            )
          ], //均分底部导航栏横向空间
        ),
      ),
    );
  }

// 使用drawer做书签
  Widget _buildBookmarkDrawer(List<TxtState> txtChapterList, pageController) {
// 获取所有的章节信息做书签的内容
    return Drawer(
      child: Column(
        children: [
          SizedBox(
            height: 60.sp,
            child: DrawerHeader(
              margin: EdgeInsets.zero,
              padding: EdgeInsets.zero,
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Padding(
                padding: EdgeInsets.zero,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      "目录",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
                itemCount: txtChapterList.length,
                itemExtent: 50.0.sp, //强制高度
                itemBuilder: (BuildContext context, int index) {
                  // 2022-07-08 不是四大名著的话，章节标题不是有两句的
                  var tempArr = (txtChapterList[index].chapterName).split(" ");

                  return ListTile(
                    title: Text(
                      "${tempArr[0]}\n${tempArr[1]} ${tempArr.length > 2 ? tempArr[2] : ''}",
                      style: TextStyle(
                        color:
                            currentChapterId == txtChapterList[index].chapterId
                                ? Colors.lightBlue
                                : Colors.black,
                        fontSize: 15.sp,
                      ),
                    ),
                    onTap: () {
                      // Update the state of the app
                      setState(() {
                        currentPage = 0;
                        currentChapterId = txtChapterList[index].chapterId;
                        getChapterDataByChapterId(
                          txtChapterList[index].txtId,
                          txtChapterList[index].chapterId,
                        );
                      });
                      // 从书签进入，都是到新章节的第一页
                      pageController.jumpToPage(0);
                      // Then close the drawer
                      Navigator.pop(context);
                    },
                  );
                }),
          ),
          // 底部留少量空间
          SizedBox(
            height: 50.sp,
          ),
        ],
      ),
    );
  }
}

// 加载中的loading组件
Widget buildLoadingWidget() {
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
              // value: .7,  /// 加了value是不会转的
            ),
          ),
        ],
      ),
    ),
  );
}
