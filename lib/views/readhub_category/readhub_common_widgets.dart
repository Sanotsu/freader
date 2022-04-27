import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 加载更多时显示的组件,给用户提示
class LoadingMoreWidget extends StatelessWidget {
  const LoadingMoreWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
}

///  都是預留的打开连接及关联报道Button
class SmallButtonWidget extends StatelessWidget {
  final GestureTapCallback onTap;
  final Widget child;
  final String tooltip;

  const SmallButtonWidget({
    Key? key,
    required this.onTap,
    required this.child,
    required this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.all(5.sp),
          child: child,
        ),
      ),
    );
  }
}
