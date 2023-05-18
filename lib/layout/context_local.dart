import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/layout/context_online.dart';
import 'package:freader/layout/markdown_page.dart';
import 'package:freader/layout/pdf_viewer_page.dart';
import 'package:freader/layout/txt_viewer_page.dart';
import 'package:freader/widgets/global_styles.dart';

class ContextLocal extends StatefulWidget {
  const ContextLocal({super.key});

  @override
  State<ContextLocal> createState() => _ContextLocalState();
}

class _ContextLocalState extends State<ContextLocal> {
  late dynamic subscription;
  String _stateText = ""; //用来显示网络状态

  @override
  void initState() {
    super.initState();
    getState();

    // 获取网络连接变化后的状态状态
    subscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      setState(() {
        _stateText = result.toString();
      });
    });
  }

  // 获取当前连接的网络
  getState() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    setState(() {
      _stateText = connectivityResult.toString();
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
          appBar: _buildAppBar(_stateText),
          body: Column(
            children: const <Widget>[
              Expanded(
                child: TabBarView(
                  children: <Widget>[
                    PdfViewerPage(),
                    MarkdownPage(),
                    TxtViewerPage(),
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
    ],
    bottom: TabBar(
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
        Tab(
          child: Text("PDF阅读器", style: blackHeadTextStyle),
        ),
        Tab(
          child: Text("内置.MD文档", style: blackHeadTextStyle),
        ),
        Tab(
          child: Text("内置TXT小说", style: blackHeadTextStyle),
        ),
      ],
    ),
  );
}
