// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/models/readhub_api_topic_detail.dart';
import 'package:freader/widgets/customized_timeline.dart';
import 'package:url_launcher/url_launcher.dart';

class ReadhubTopicDetailDialog extends StatefulWidget {
  final ReadhubApiTopicDetailData topicDetail;

  const ReadhubTopicDetailDialog({Key? key, required this.topicDetail})
      : super(key: key);

  @override
  State<ReadhubTopicDetailDialog> createState() =>
      _ReadhubTopicDetailDialogState();
}

class _ReadhubTopicDetailDialogState extends State<ReadhubTopicDetailDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color.fromARGB(255, 187, 216, 154),
      title: Text(
        '详情追踪',
        style: TextStyle(
            fontSize: 12.0.sp, fontWeight: FontWeight.bold, fontFamily: 'Hind'),
      ),
      content: setupAlertDialoadContainer(widget.topicDetail),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("返回"),
        )
      ],
    );
  }
}

// 构建alert dialog 正文content部分
Widget setupAlertDialoadContainer(ReadhubApiTopicDetailData topicDetail) {
  return Container(
    height: 310.sp, // 34 + 116 +34 +116 （媒体报道文字+内容+事件追踪文字+内容）
    width: 300.sp, // 好像没法设定宽度？
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(15),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(top: 10.0.sp, bottom: 10.0.sp),
          child: Text(
            '媒体报道',
            style: TextStyle(
                fontSize: 10.0.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind'),
          ),
        ),
        buildNewsAggListInDialog(topicDetail.newsArray),
        Padding(
          padding: EdgeInsets.only(top: 10.0.sp, bottom: 10.0.sp),
          child: Text(
            '事件追踪',
            style: TextStyle(
                fontSize: 10.0.sp,
                fontWeight: FontWeight.bold,
                fontFamily: 'Hind'),
          ),
        ),
        buildTimelineInDialog(topicDetail.newsArray),
      ],
    ),
  );
}

// 指定【热门话题】弹窗的关联新闻部分。
Widget buildNewsAggListInDialog(List<NewsArrayData>? topicDetailNewsArray) {
  List<NewsArrayData> newsArray = topicDetailNewsArray ?? [];

  return SizedBox(
    height: 116.sp,
    child: ListView.builder(
      shrinkWrap: true,
      itemCount: newsArray.length,
      itemBuilder: (context, index) {
        return Flex(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          direction: Axis.horizontal,
          children: [
            Expanded(
              flex: 3,
              child: GestureDetector(
                onTap: () async {
                  // 先关闭_showNewsDialog中创建的 ModalBottomSheet
                  Navigator.pop(context);
                  // 再在应用內打开url
                  var url = Uri.parse("${newsArray[index].url}");
                  // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                  if (await canLaunchUrl(url)) {
                    await launchUrl(
                      url,
                      mode: LaunchMode.inAppWebView,
                      webViewConfiguration: const WebViewConfiguration(
                        enableJavaScript: true,
                        enableDomStorage: true,
                      ),
                    );
                  } else {
                    throw 'Could not launch $url';
                  }
                },
                child: SizedBox(
                  height: 20.0.sp,
                  child: Text(
                    "${newsArray[index].title}",
                    softWrap: true,
                    textAlign: TextAlign.left,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 10.sp,
                    ),
                  ),
                ),
              ),
            ),
            // 不加Expanded，不知道Text的宽度，则不会以省略号显示。
            Expanded(
              flex: 1,
              child: SizedBox(
                height: 20.0.sp,
                child: Text(
                  "${newsArray[index].siteName}",
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 10.sp,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

// 指定【热门话题】弹窗的时间线部分。
Widget buildTimelineInDialog(topicDetailNewsArray) {
  List<NewsArrayData> newsArray = topicDetailNewsArray ?? [];

  /// 要时间倒序如何弄？list先重新排序？

  return SizedBox(
    height: 116.sp,
    child: ListView.builder(
      itemCount: newsArray.length,
      itemBuilder: (BuildContext context, int index) {
        return Stack(
          children: <Widget>[
            // 标题部分(8.sp的时间字符串，长度大概为75)左边空80.sp。
            Padding(
              padding: const EdgeInsets.only(left: 80.0),
              child: Card(
                color: const Color.fromARGB(255, 233, 229, 220),
                child: GestureDetector(
                  onTap: () async {
                    // 再在应用內打开url
                    var url = Uri.parse("${newsArray[index].url}");
                    // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                    if (await canLaunchUrl(url)) {
                      await launchUrl(
                        url,
                        mode: LaunchMode.inAppWebView,
                        webViewConfiguration: const WebViewConfiguration(
                          enableJavaScript: true,
                          enableDomStorage: true,
                        ),
                      );
                    } else {
                      throw 'Could not launch $url';
                    }
                  },
                  child: SizedBox(
                    height: 30.0.sp,
                    child: RichText(
                      maxLines: 2,
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        children: <TextSpan>[
                          TextSpan(
                            text: "${newsArray[index].siteName}    ",
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 8.sp,
                            ),
                          ),
                          TextSpan(
                            text: "${newsArray[index].title}",
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 8.sp,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // 竖线部分
            Positioned(
              top: 0.0,
              bottom: 0.0,
              left: 75.0, // 左边空75.sp给时间字符串
              child: Container(
                height: double.infinity,
                width: 1.0,
                color: Colors.blue,
              ),
            ),
            // 时间字符串部分
            Positioned(
              top: 15.0, // 标题文字SizedBox高度的一半，显示居中
              left: 0.0,
              child: Text(
                "${newsArray[index].getPublishDate()}",
                softWrap: true,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 8.sp,
                ),
              ),
            ),
          ],
        );
      },
    ),
  );
}

/// 指定【热门话题】弹窗的时间线部分。 --- 使用utils/customized_timeline.dart 部分，效果也不佳
/// 无法简单调整时间可完整显示。
Widget buildTimelineInDialog2(topicDetailNewsArray) {
  List<NewsArrayData> newsArray = topicDetailNewsArray ?? [];

// customized_timeline Timeline需要的两个widget列表
  List<Widget> childrenList = <Widget>[];
  List<Widget> indicatorsList = <Widget>[];

  for (var i = 0; i < newsArray.length; i++) {
    childrenList.add(
      // 橫向排列，title和siteNameDisplay占比为3:1。改为Row，不要direction属性是一样的。
      Flex(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        direction: Axis.horizontal,
        children: [
          Expanded(
            flex: 3,
            child: GestureDetector(
              onTap: () async {
                // 再在应用內打开url
                var url = Uri.parse("${newsArray[i].url}");
                // 应用内打开ok，但原文章没有自适应手机的话，看起來就很別扭。
                if (await canLaunchUrl(url)) {
                  await launchUrl(
                    url,
                    mode: LaunchMode.inAppWebView,
                    webViewConfiguration: const WebViewConfiguration(
                      enableJavaScript: true,
                      enableDomStorage: true,
                    ),
                  );
                } else {
                  throw 'Could not launch $url';
                }
              },
              child: SizedBox(
                height: 10.0.sp,
                child: Text(
                  "${newsArray[i].title}",
                  softWrap: true,
                  textAlign: TextAlign.left,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 8.sp,
                  ),
                ),
              ),
            ),
          ),
          // 不加Expanded，不知道Text的宽度，则不会以省略号显示。
          Expanded(
            flex: 1,
            child: SizedBox(
              height: 10.0.sp,
              child: Text(
                "${newsArray[i].siteName}",
                softWrap: true,
                textAlign: TextAlign.left,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.blueGrey,
                  fontSize: 8.sp,
                ),
              ),
            ),
          ),
        ],
      ),
    );

    indicatorsList.add(
      SizedBox(
        height: 10.0.sp,
        child: Text(
          "${newsArray[i].getPublishDate()}",
          softWrap: true,
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
          style: TextStyle(
            color: Colors.blueGrey,
            fontSize: 8.sp,
          ),
        ),
      ),
    );
  }

  return Timeline(
    indicators: indicatorsList,
    children: childrenList,
  );
}
