// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/readhub_api_result.dart';
import 'package:freader/utils/platform_util.dart';

const double leading = 1;
const double textLineHeight = 0.5;
const letterSpacing = 1.0;
const articleTextScaleFactor = 1.0;

///文章适配器
class ArticleAdapter extends StatelessWidget {
  const ArticleAdapter(
    this.item, {
    Key? key,
  }) : super(key: key);
  final ItemsData item;

  @override
  Widget build(BuildContext context) {
    print("xxxxxxxxxxxxxxxxxxxxx");
    print(item);

    return Container(
      padding: const EdgeInsets.only(top: 12),
      margin: const EdgeInsets.symmetric(horizontal: 12),

      ///分割线
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 3.sp),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "${item.title}",
            style: Theme.of(context).textTheme.bodyText1,
          ),

          ///标题
          Text(
            '${item.title}',
            textScaleFactor: 1,
            maxLines: 1,
            strutStyle: const StrutStyle(
              forceStrutHeight: false,
              height: 0.5,
              leading: leading,
            ),

            ///浏览器...显示异常
            overflow:
                PlatformUtil.isWeb ? TextOverflow.fade : TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.subtitle2!.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: letterSpacing,
                ),
          ),
          const SizedBox(
            height: 6,
          ),

          ///描述摘要
          Expanded(
            flex: 1,
            child: Text(
              item.summary ?? "暂无摘要",
              textScaleFactor: articleTextScaleFactor,
              maxLines: PlatformUtil.isMobile
                  ? true
                      ? 3
                      // ignore: dead_code
                      : 10000
                  : 3,

              ///浏览器...显示异常
              overflow: PlatformUtil.isWeb
                  ? TextOverflow.fade
                  : TextOverflow.ellipsis,
              strutStyle: const StrutStyle(
                forceStrutHeight: false,
                height: textLineHeight,
                leading: leading,
              ),
              style: Theme.of(context).textTheme.caption!.copyWith(
                  letterSpacing: letterSpacing,
                  color: Theme.of(context)
                      .textTheme
                      .headline6!
                      .color!
                      .withOpacity(0.8)),
            ),
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  item.createdAt ?? "未知事件",
                  textScaleFactor: articleTextScaleFactor,
                  maxLines: 2,

                  ///浏览器...显示异常
                  overflow: PlatformUtil.isWeb
                      ? TextOverflow.fade
                      : TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.caption!.copyWith(
                        fontSize: 12,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
