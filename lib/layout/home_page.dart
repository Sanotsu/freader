import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/layout/context_local.dart';
import 'package:freader/layout/context_online.dart';
import 'package:freader/utils/global_styles.dart';
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
  static const List<Widget> _widgetOptions = <Widget>[
    ContextOnline(),
    ContextLocal(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.newspaper), label: '在线新闻'),
          BottomNavigationBarItem(icon: Icon(Icons.text_fields), label: '本地资源'),
        ],
        currentIndex: _selectedIndex,
        // 底部导航栏的颜色
        backgroundColor: Theme.of(context).primaryColor,
        // 被选中的item的图标颜色和文本颜色
        selectedIconTheme: const IconThemeData(color: Colors.white),
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}

// 主页的左侧抽屉drawer
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
