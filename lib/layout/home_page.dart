// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/layout/image_page.dart';
import 'package:freader/layout/markdown_page.dart';
import 'package:freader/layout/news_page.dart';
import 'package:freader/layout/pdf_viewer_page.dart';
import 'package:freader/layout/tools_page.dart';
import 'package:freader/layout/txt_viewer_page.dart';
import 'package:freader/utils/global_styles.dart';
import 'package:freader/widgets/hitokoto_sentence.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

///
/// 2022-04-21
/// 结构应该是这样的：
/// HomePage中的 TabBar 显示的是第一层菜单 ： news image video tool poetry ……（預留，先只有news和一个拿几张本地图片占位的image）
///     切到 NewsPage 中，再选择第二层菜单，新闻來源 ： readhub newsapi newsdata ……
///         切到 ReadhubPage 中，再选择第三层菜单，该服务中有的分类： topics daily news tech ……
///
/// 以上是不是都是一样tabbar还是其他怎样，看学习水平。这样一直用tabbar好像用不到路由了？
///

class HomePage extends StatefulWidget {
  const HomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  var subscription;
  String _stateText = ""; //用来显示状态

  @override
  void initState() {
    super.initState();
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _stateText = result.toString();
      });

      // if (result == ConnectivityResult.wifi) {
      //   setState(() {
      //     _stateText = "当前处于wifi网络";
      //   });
      // } else if (result == ConnectivityResult.mobile) {
      //   setState(() {
      //     _stateText = "当前处于数据流量网络";
      //   });
      // } else if (result == ConnectivityResult.none) {
      //   setState(() {
      //     _stateText = "当前无网络连接";
      //   });
      // } else {
      //   setState(() {
      //     _stateText = "处于其他连接";
      //   });
      // }
    });

    print(_stateText);
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 6,
      child: Scaffold(
        // appBar: PreferredSize(
        //     preferredSize: Size.fromHeight(0.1.sh), // here the desired height
        //     child: const HomeAppBar()),
        // 2022-05-14 使用默认样式大小
        appBar: _buildAppBar(),
        body: const TabBarView(
          children: [
            NewsPage(),
            MarkdownPage(),
            ImagePage(),
            ToolsPage(),
            PdfViewerPage(),
            TxtViewerPage(),
          ],
        ),
        // 主页侧边抽屉组件
        drawer: HomeDrawer(networkState: _stateText),
        bottomNavigationBar: const HomeBottomAppBar(),
        // bottomNavigationBar: const HomeBottomNavigationBar(),
        // 漂浮在body上方的按钮，默认右下角(如果要悬浮按钮和下方导航条一起用，HomeBottomAppBar比HomeBottomNavigationBar好)
        floatingActionButton: SizedBox(
          height: 30.0.sp,
          width: 30.0.sp,
          child: FittedBox(
            child: FloatingActionButton(
              onPressed: () => {},
              tooltip: 'Increment',
              child: Icon(
                Icons.add,
                size: 20.sp,
              ),
            ),
          ),
        ),

        // 悬浮按钮底部居中
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniEndDocked,
      ),
    );
  }
}

/// 2022-5-14 主页的appBar
/// 使用默认样式
_buildAppBar() {
  return AppBar(
    title: Text("Let's freader", style: appBarTextStyle),
    actions: <Widget>[
      IconButton(
        iconSize: appBarIconButtonSize,
        icon: const Icon(
          Icons.search,
          semanticLabel: 'search', // icon的语义标签。
        ),
        onPressed: () {},
      ),
      IconButton(
        iconSize: appBarIconButtonSize,
        icon: const Icon(
          Icons.scanner,
          semanticLabel: 'scanner',
        ),
        onPressed: () {},
      ),
    ],
    bottom: TabBar(
      // // 可以使得tab的文本自适应显示长度，很长的内容都会显示完整。
      // isScrollable: true,
      // // 标签左右空10dp，上下无空
      // labelPadding: EdgeInsets.symmetric(horizontal: 10.0),
      /// TabBar 的下划线的样式
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(width: 2.0.sp), // 下划线的粗度
        // 下划线的四边的间距horizontal橫向
        insets: EdgeInsets.symmetric(horizontal: 2.0.sp),
      ),
      // 出现在被选择的Tab下面的线的厚度。
      indicatorWeight: 5.sp,
      indicatorSize: TabBarIndicatorSize.label,
      isScrollable: true,
      tabs: [
        SizedBox(
          width: tabWidth,
          child: Tab(
            child: Text("各式新闻", style: blackHeadTextStyle),
          ),
        ),
        SizedBox(
          width: tabWidth,
          child: Tab(
            child: Text("技术文章", style: blackHeadTextStyle),
          ),
        ),
        SizedBox(
          width: tabWidth,
          child: Tab(
            child: Text("开源图片", style: blackHeadTextStyle),
          ),
        ),
        SizedBox(
          width: tabWidth,
          child: Tab(
            child: Text("实用工具", style: blackHeadTextStyle),
          ),
        ),
        SizedBox(
          width: tabWidth,
          child: Tab(
            child: Text("PDF阅读器", style: blackHeadTextStyle),
          ),
        ),
        SizedBox(
          width: tabWidth,
          child: Tab(
            child: Text("内置小说", style: blackHeadTextStyle),
          ),
        ),
      ],
    ),
  );
}

// 主页的左侧抽屉drawer
class HomeDrawer extends StatelessWidget {
  const HomeDrawer({Key? key, required this.networkState}) : super(key: key);

  final String networkState;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: MediaQuery.removePadding(
        context: context,
        //移除抽屉菜单顶部默认留白
        removeTop: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // drawer header
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.blue,
              ),
              child: Padding(
                // 与顶部间隔0.05个高度
                padding: EdgeInsets.only(top: 0.05.sh),
                child: Row(
                  children: <Widget>[
                    Padding(
                      // 创建具有对称的垂直vertical和水平horizontal偏移的嵌套。水平偏移5dp
                      padding: EdgeInsets.symmetric(horizontal: 5.sp),
                      child: ClipOval(
                        child: Image.asset(
                          "images/avatar.png",
                          width: 80,
                        ),
                      ),
                    ),
                    const Text(
                      "Sanot Su",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50.sp,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    text: '当前网络: ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: sizeContent2,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                          text: networkState,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: sizeContent2,
                          )),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: const <Widget>[
                  ListTile(
                    leading: Icon(Icons.add),
                    title: Text('Add account'),
                  ),
                  ListTile(
                    leading: Icon(Icons.settings),
                    title: Text('Manage accounts'),
                  ),
                  HitokotoSentence(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 主页底部的导航栏
// BottomAppBar
// BottomAppBar:一个通常与Scaffold.bottomNavigationBar一起使用的容器，
// 可以沿着顶部有一个缺口，为一个重叠的FloatingActionButton留出空间。
class HomeBottomAppBar extends StatefulWidget {
  const HomeBottomAppBar({Key? key}) : super(key: key);

  @override
  State<HomeBottomAppBar> createState() => _HomeBottomAppBarState();
}

class _HomeBottomAppBarState extends State<HomeBottomAppBar> {
  Color _iconHomeColor = Colors.lightBlue;
  Color _iconColor = Colors.lightBlue;
// 简单示例：点击了按钮改变其颜色
  void _onItemPressed() {
    setState(() {
      if (_iconColor == Colors.lightBlue) {
        _iconColor = Colors.red;
      } else {
        _iconColor = Colors.lightBlue;
      }
    });
  }

  void _onHomeItemPressed() {
    setState(() {
      _iconHomeColor == Colors.lightBlue
          ? _iconHomeColor = Colors.red
          : _iconHomeColor = Colors.lightBlue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Colors.white,
      shape: const CircularNotchedRectangle(), // 底部导航栏打一个圆形的洞
      child: SizedBox(
        height: 40.sp,
        child: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.home,
                color: _iconHomeColor,
                size: appBarIconButtonSize,
              ),
              onPressed: _onHomeItemPressed,
            ),
            const SizedBox(), //中间位置空出
            IconButton(
              icon: Icon(
                Icons.business,
                color: _iconColor,
                size: appBarIconButtonSize,
              ),
              onPressed: _onItemPressed,
            ),
          ],
          mainAxisAlignment: MainAxisAlignment.spaceAround, //均分底部导航栏横向空间
        ),
      ),
    );
  }
}

/// 主页底部的导航栏
// BottomNavigationBar
// 一个显示在应用程序底部的材料小部件，用于在少量的视图中进行选择，通常在三到五个之间。
// 底部导航栏由文本标签、图标或两者形式的多个项目组成，铺设在一块材料的顶部。它提供了一个应用程序的顶层视图之间的快速导航。
// 底部导航条通常与Scaffold一起使用，它被作为Scaffold.bottomNavigationBar参数提供。
class HomeBottomNavigationBar extends StatefulWidget {
  const HomeBottomNavigationBar({Key? key}) : super(key: key);

  @override
  State<HomeBottomNavigationBar> createState() =>
      _HomeBottomNavigationBarState();
}

class _HomeBottomNavigationBarState extends State<HomeBottomNavigationBar> {
  int _selectedIndex = 1;

  void _onItemPressed(int index) {
    setState(() {
      _selectedIndex = index;
    });

    print(_selectedIndex);
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      // 底部导航
      items: const <BottomNavigationBarItem>[
        BottomNavigationBarItem(
            icon: Icon(
              Icons.home,
              color: Colors.lightBlue,
            ),
            label: 'Home'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.business,
              color: Colors.lightBlue,
            ),
            label: 'Business'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.school,
              color: Colors.lightBlue,
            ),
            label: 'School'),
        BottomNavigationBarItem(
            icon: Icon(
              Icons.mail,
              color: Colors.lightBlue,
            ),
            label: 'Mail'),
      ],
      currentIndex: _selectedIndex,
      fixedColor: Colors.blue,
      onTap: _onItemPressed,
    );
  }
}
