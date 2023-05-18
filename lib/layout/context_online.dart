import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/layout/home_page.dart';
import 'package:freader/layout/image_page.dart';
import 'package:freader/layout/news_page.dart';
import 'package:freader/layout/tools_page.dart';
import 'package:freader/widgets/global_styles.dart';

class ContextOnline extends StatefulWidget {
  const ContextOnline({super.key});

  @override
  State<ContextOnline> createState() => _ContextOnlineState();
}

class _ContextOnlineState extends State<ContextOnline> {
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: DefaultTabController(
        length: 3,
        child: Scaffold(
          // 避免搜索时弹出键盘，让底部的minibar位置移动到tab顶部导致溢出的问题
          resizeToAvoidBottomInset: false,
          // 主页侧边抽屉组件
          drawer: HomeDrawer(networkState: _stateText),
          appBar: _buildAppBar(_stateText),
          body: Column(
            children: const <Widget>[
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    NewsPage(),
                    ToolsPage(),
                    ImagePage(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

_buildAppBar(String networkState) {
  var labelChar = "";
  var temp = networkState.split(".");
  if (temp.length > 1) {
    labelChar = temp[1];
  }

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
      // IconButton(
      //   iconSize: appBarIconButtonSize,
      //   icon: const Icon(
      //     Icons.logout_outlined,
      //     color: Colors.greenAccent,
      //     semanticLabel: 'logout', // icon的语义标签。
      //   ),
      //   onPressed: () {},
      // ),
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
            child: Text("聚合新闻", style: blackHeadTextStyle),
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
            child: Text("开源图片", style: blackHeadTextStyle),
          ),
        ),
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
