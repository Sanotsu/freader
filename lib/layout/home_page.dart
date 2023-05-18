import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/layout/image_page.dart';
import 'package:freader/layout/markdown_page.dart';
import 'package:freader/layout/news_page.dart';
import 'package:freader/layout/pdf_viewer_page.dart';
import 'package:freader/layout/tools_page.dart';
import 'package:freader/layout/txt_viewer_page.dart';
import 'package:freader/widgets/global_styles.dart';
import 'package:freader/views/login_screen.dart';
import 'package:freader/widgets/hitokoto_sentence.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
// 默认选中的是哪一个底部导航
  int _selectedIndex = 0;

// 底部导航列表
  final List<Widget> _widgetOptions = const <Widget>[
    TabBarView(children: [NewsPage(), ToolsPage(), ImagePage()]),
    TabBarView(children: [PdfViewerPage(), MarkdownPage(), TxtViewerPage()]),
  ];

  // 获取当前网络状态和网络切换后的状态
  late StreamSubscription<ConnectivityResult> subscription;
  String _stateText = ""; //用来显示网络状态

  @override
  void initState() {
    super.initState();

    // 获取当前网络状态
    Connectivity().checkConnectivity().then((value) {
      setState(() {
        _stateText = value.toString();
      });
    });

    // 获取网络连接变化后的状态状态
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _stateText = result.toString();
      });
    });
  }

  @override
  dispose() {
    subscription.cancel();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          // 避免搜索时弹出键盘，让底部的minibar位置移动到tab顶部导致溢出的问题
          resizeToAvoidBottomInset: false,
          drawer: HomeDrawer(networkState: _stateText),
          appBar: _buildAppBar(_stateText, _selectedIndex),
          body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
          bottomNavigationBar: BottomNavigationBar(
            items: const <BottomNavigationBarItem>[
              BottomNavigationBarItem(
                  icon: Icon(Icons.newspaper), label: '联网资源'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.text_fields), label: '本地资源'),
            ],
            currentIndex: _selectedIndex,
            // 底部导航栏的颜色
            backgroundColor: Theme.of(context).primaryColor,
            // 被选中的item的图标颜色和文本颜色
            selectedIconTheme: const IconThemeData(color: Colors.white),
            selectedItemColor: Colors.white,
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }
}

/// 构建appbar中的内容
// 除了标题、网络状态图标，还有底部导航栏切换后，对应tab和tabview的内容
_buildAppBar(String networkState, int bottomNavIndex) {
  var labelChar = "";
  var temp = networkState.split(".");
  if (temp.length > 1) {
    labelChar = temp[1];
  }

  // 简单弄一个tab标题文字的样式
  var tabStyle = TextStyle(
    fontFamily: "BarlowBold",
    fontSize: 16.sp,
    color: Colors.black,
  );

  return AppBar(
    title: Text("Let's freader", style: appBarTextStyle),
    actions: <Widget>[
      // 当前网络连接方式图标（数据流量、wifi、其他无网）
      SizedBox(
        width: 60.sp,
        child: Center(
          child: Text(
            labelChar != "" ? labelChar : networkState,
            style: const TextStyle(color: Colors.orange),
          ),
        ),
      ),
      genNetworkStateIcon(networkState),
      SizedBox(width: 20.sp)
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
      tabs: bottomNavIndex == 0
          ? [
              Tab(child: Text("聚合新闻", style: tabStyle)),
              Tab(child: Text("实用工具", style: tabStyle)),
              Tab(child: Text("开源图片", style: tabStyle)),
            ]
          : [
              Tab(child: Text("PDF阅读器", style: tabStyle)),
              Tab(child: Text("内置.MD文档", style: tabStyle)),
              Tab(child: Text("内置TXT小说", style: tabStyle)),
            ],
    ),
  );
}

// 显示网络状态的图标
Widget genNetworkStateIcon(String networkState) {
  if (networkState == "ConnectivityResult.wifi") {
    return Icon(
      Icons.network_wifi,
      color: Colors.green,
      size: appBarIconButtonSize,
    );
  } else if (networkState == "ConnectivityResult.mobile") {
    return Icon(
      Icons.network_cell,
      color: Colors.orange,
      size: appBarIconButtonSize,
    );
  } else {
    return Icon(
      Icons.network_locked,
      color: Colors.red,
      size: appBarIconButtonSize,
    );
  }
}

/// 主页的左侧抽屉drawer
class HomeDrawer extends StatefulWidget {
  const HomeDrawer({Key? key, required this.networkState}) : super(key: key);

  final String networkState;

  @override
  State<HomeDrawer> createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  String _userName = ""; //用来显示登入的用户名称

  // 点击退出后，清除登入状态为false
  Future<void> saveLoginState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(GlobalConstants.loginState, false);
  }

  // 获取登入账号
  getLoginUser() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _userName = prefs.getString(GlobalConstants.loginAccount) ?? "";
    });
  }

  @override
  void initState() {
    getLoginUser();
    super.initState();
  }

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
                        child: Image.asset("images/avatar.png", width: 80),
                      ),
                    ),
                    Text(
                      _userName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: sizeContent1,
                      ),
                    )
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView(
                children: <Widget>[
                  ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: '当前网络: ',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: sizeContent2,
                        ),
                        children: <TextSpan>[
                          TextSpan(
                              text: widget.networkState,
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: sizeContent2,
                              )),
                        ],
                      ),
                    ),
                  ),
                  // const ListTile(
                  //   leading: Icon(Icons.add),
                  //   title: Text('Add account'),
                  // ),
                  // const ListTile(
                  //   leading: Icon(Icons.settings),
                  //   title: Text('Manage accounts'),
                  // ),
                  ListTile(
                    leading: const Icon(Icons.logout_outlined),
                    title: const Text(
                      '退出当前账号',
                      style: TextStyle(
                        color: Colors.lightBlue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    onTap: () async {
                      // 点击退出按钮后，清除登入状态为false，并跳转到登陆页
                      await saveLoginState();
                      if (!mounted) return;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                  ),
                  const HitokotoSentence(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
