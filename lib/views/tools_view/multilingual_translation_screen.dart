// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/utils/global_styles.dart';
import 'package:freader/views/tools_view/fetch_translation_result.dart';

// 翻译语言选择下拉框对象
// label用于显示，value用于传给后台查询
class LangItem {
  String langValue;
  String langlabel;

  LangItem({
    required this.langValue,
    required this.langlabel,
  });
}

/// 多国语言翻译显示页面
class MultilingualTranslationScreen extends StatefulWidget {
  const MultilingualTranslationScreen({Key? key}) : super(key: key);

  @override
  State<MultilingualTranslationScreen> createState() =>
      _MultilingualTranslationScreenState();
}

class _MultilingualTranslationScreenState
    extends State<MultilingualTranslationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("多国语言翻译"),
        ),
        body: const CustomerForm());
  }
}

class CustomerForm extends StatefulWidget {
  const CustomerForm({Key? key}) : super(key: key);

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  // 翻译结果文本框控制器
  final targetTextController = TextEditingController();
  // 源文本输入框控制器
  final sourceTextController = TextEditingController();
  String translationResultText = "";

  LangItem sourceLang = LangItem(langValue: "en", langlabel: "English");
  LangItem targetLang = LangItem(langValue: "zh", langlabel: "中文");

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    targetTextController.addListener(_printLatestValue);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the widget tree.
    // This also removes the _printLatestValue listener.
    targetTextController.dispose();
    super.dispose();
  }

  getTranslationResult() async {
    var transRst = await fetchLibreTranslateResult(
        sourceTextController.text, sourceLang.langValue, targetLang.langValue);
    setState(() {
      translationResultText = transRst["translatedText"];
      targetTextController.text = transRst["translatedText"];
    });
  }

  void _printLatestValue() {
    print('Second text field: ${targetTextController.text}');
  }

  @override
  Widget build(BuildContext context) {
    List<LangItem> langLabels = [
      LangItem(langValue: "zh", langlabel: "中文"),
      LangItem(langValue: "en", langlabel: "English"),
      LangItem(langValue: "ja", langlabel: "Japanese"),
      LangItem(langValue: "ar", langlabel: "Arabic"),
      LangItem(langValue: "az", langlabel: "Azerbaijani"),
      LangItem(langValue: "cz", langlabel: "Czech"),
      LangItem(langValue: "da", langlabel: "Danish"),
      LangItem(langValue: "nl", langlabel: "Dutch"),
      LangItem(langValue: "eo", langlabel: "Esperanto"),
      LangItem(langValue: "fi", langlabel: "Finnish"),
      LangItem(langValue: "fr", langlabel: "French"),
      LangItem(langValue: "de", langlabel: "German"),
      LangItem(langValue: "el", langlabel: "Greek"),
      LangItem(langValue: "he", langlabel: "Hebrew"),
      LangItem(langValue: "hi", langlabel: "Hindi"),
      LangItem(langValue: "hu", langlabel: "Hungarian"),
      LangItem(langValue: "id", langlabel: "Indonesian"),
      LangItem(langValue: "ga", langlabel: "Irish"),
      LangItem(langValue: "it", langlabel: "Italian"),
      LangItem(langValue: "ko", langlabel: "Korean"),
      LangItem(langValue: "fa", langlabel: "Persian"),
      LangItem(langValue: "pl", langlabel: "Polish"),
      LangItem(langValue: "pt", langlabel: "Portuguese"),
      LangItem(langValue: "ru", langlabel: "Russian"),
      LangItem(langValue: "sk", langlabel: "Slovak"),
      LangItem(langValue: "es", langlabel: "Spanish"),
      LangItem(langValue: "sv", langlabel: "Swedish"),
      LangItem(langValue: "tr", langlabel: "Turkish"),
      LangItem(langValue: "uk", langlabel: "Ukranian"),
      LangItem(langValue: "vi", langlabel: "Vietnamese"),
      LangItem(langValue: "auto", langlabel: "自动检测"),
    ];

    return Column(
      children: [
        SizedBox(
          height: 50.sp,
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  "切换引擎预留位置",
                  style: TextStyle(fontSize: sizeHeadline3),
                ),
              ),
              Expanded(
                flex: 2,
                // source语言下拉框（这个后续可以封装一下）
                child: Center(
                  child: DropdownButton<String>(
                    // 下拉框中显示的值
                    value: sourceLang.langlabel,
                    // icon: const Icon(Icons.arrow_downward),
                    style: const TextStyle(color: Colors.deepPurple),
                    // 下拉框下划线的样式
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    // 当下拉框值变化之后触发的函数，在这里获取选中的值
                    onChanged: (String? newValue) {
                      setState(() {
                        // 获取选中的label，要取得对应的langValue,过滤默认数组，有重复取第一个
                        sourceLang = langLabels
                            .where((e) => e.langlabel == newValue)
                            .first;
                      });
                      // 切换语言后也重新查询
                      if (sourceTextController.text != "") {
                        getTranslationResult();
                      }
                    },
                    // 用于显示的列表（使用了LangItem类，取其label用于显示）
                    items: langLabels.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value.langlabel,
                        // 下拉框中显示的组件，可以是个Text，还可以是别的什么
                        child: Text(value.langlabel),
                        // child: const Icon(Icons.wifi),
                      );
                    }).toList(),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: 48.sp,
                  child: Center(
                    child: Text(
                      "翻译为",
                      style: TextStyle(fontSize: sizeHeadline3),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 2,
                child: Center(
                  child: DropdownButton<String>(
                    // 下拉框中显示的值
                    value: targetLang.langlabel,
                    // icon: const Icon(Icons.arrow_downward),
                    elevation: 16,
                    style: const TextStyle(color: Colors.deepPurple),
                    underline: Container(
                      height: 2,
                      color: Colors.deepPurpleAccent,
                    ),
                    // 当下拉框值变化之后触发的函数，在这里获取选中的值
                    onChanged: (String? newValue) {
                      setState(() {
                        // 获取选中的label，要取得对应的langValue,过滤默认数组，有重复取第一个
                        targetLang = langLabels
                            .where((e) => e.langlabel == newValue)
                            .first;
                      });
                      // 切换语言后也重新查询
                      if (sourceTextController.text != "") {
                        getTranslationResult();
                      }
                    },
                    // 用于显示的列表（使用了LangItem类，取其label用于显示）
                    items: langLabels.map<DropdownMenuItem<String>>((value) {
                      return DropdownMenuItem<String>(
                        value: value.langlabel,
                        // 下拉框中显示的组件，可以是个Text，还可以是别的什么
                        child: Text(value.langlabel),
                        // child: const Icon(Icons.wifi),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        // 间隔高度(预留文字转语音)
        SizedBox(
          height: 30.sp,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 25.sp,
                    child: Container(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 25.sp,
                    child: IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        size: 20.sp,
                      ),
                      tooltip: '预留翻译后语言朗读',
                      onPressed: () {},
                    ),
                  ),
                ),
              ]),
        ),
        // 输入框占屏幕1/3
        SizedBox(
          height: 0.3.sh,
          child: TextField(
            // 文本框边框样式
            decoration: InputDecoration(
              labelText: "输入文字",
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide(color: Colors.grey, width: 2.0.sp),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: Colors.blueGrey,
                  width: 2.0.sp,
                ),
                // 边框圆角弧度半径
                borderRadius: BorderRadius.circular(5.0.sp),
              ),
            ),
            maxLines: 8,
            controller: sourceTextController,
            onChanged: (text) {
              print('First text field: $text');
              // 如果有输入源文本，进行查询。
              if (text != "") {
                getTranslationResult();
              } else {
                // 如果清空了输入，翻译结果的内容也清空
                setState(() {
                  translationResultText = "";
                  targetTextController.text = "";
                });
              }
            },
          ),
        ),
        // 间隔高度(预留文字转语音)
        SizedBox(
          height: 30.sp,
          child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  flex: 3,
                  child: SizedBox(
                    height: 25.sp,
                    child: Container(),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 25.sp,
                    child: IconButton(
                      icon: Icon(
                        Icons.volume_up,
                        size: 20.sp,
                      ),
                      tooltip: '预留翻译后语言朗读',
                      onPressed: () {},
                    ),
                  ),
                ),
              ]),
        ),

        Expanded(
          child: SizedBox(
            height: 0.3.sh,
            child: TextField(
              readOnly: true,
              // 文本框边框样式
              decoration: InputDecoration(
                labelText: "翻译结果",
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                  borderSide: BorderSide(color: Colors.grey, width: 2.0.sp),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.blueGrey,
                    width: 2.0.sp,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
              maxLines: 8,
              controller: targetTextController,
            ),
          ),
        ),
      ],
    );
  }
}
