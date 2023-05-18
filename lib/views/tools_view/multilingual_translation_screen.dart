// ignore_for_file: avoid_print, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:freader/widgets/global_styles.dart';
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
        resizeToAvoidBottomInset: false,
        body: const Material(
          child: CustomerForm(),
        ));
  }
}

class CustomerForm extends StatefulWidget {
  const CustomerForm({Key? key}) : super(key: key);

  @override
  State<CustomerForm> createState() => _CustomerFormState();
}

class _CustomerFormState extends State<CustomerForm> {
  // 翻译引擎列表
  var translationEngineList = ["百度翻译", "自由翻译"];

  // LibreTranslate常见语种列表
  List<LangItem> libreTranslateLangLabels = [
    LangItem(langValue: "zh", langlabel: "中文"),
    LangItem(langValue: "en", langlabel: "英语"),
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

  // 百度翻译常见语种列表
  List<LangItem> baiduFanyiLangLabels = [
    LangItem(langValue: "auto", langlabel: "自动检测"),
    LangItem(langValue: "zh", langlabel: "中文"),
    LangItem(langValue: "en", langlabel: "英语"),
    LangItem(langValue: "cht", langlabel: "繁体中文"),
    LangItem(langValue: "jp", langlabel: "日语"),
    LangItem(langValue: "kor", langlabel: "韩语"),
    LangItem(langValue: "yue", langlabel: "粤语"),
    LangItem(langValue: "wyw", langlabel: "文言文"),
    LangItem(langValue: "fra", langlabel: "法语"),
    LangItem(langValue: "spa", langlabel: "西班牙语"),
    LangItem(langValue: "th", langlabel: "泰语"),
    LangItem(langValue: "ara", langlabel: "阿拉伯语"),
    LangItem(langValue: "ru", langlabel: "俄语"),
    LangItem(langValue: "pt", langlabel: "葡萄牙语"),
    LangItem(langValue: "de", langlabel: "德语"),
    LangItem(langValue: "it", langlabel: "意大利语"),
    LangItem(langValue: "el", langlabel: "希腊语"),
    LangItem(langValue: "nl", langlabel: "荷兰语"),
    LangItem(langValue: "pl", langlabel: "波兰语"),
    LangItem(langValue: "bul", langlabel: "保加利亚语"),
    LangItem(langValue: "est", langlabel: "爱沙尼亚语"),
    LangItem(langValue: "dan", langlabel: "丹麦语"),
    LangItem(langValue: "fin", langlabel: "芬兰语"),
    LangItem(langValue: "cs", langlabel: "捷克语"),
    LangItem(langValue: "rom", langlabel: "罗马尼亚语"),
    LangItem(langValue: "ru", langlabel: "斯洛文尼亚语"),
    LangItem(langValue: "swe", langlabel: "瑞典语"),
    LangItem(langValue: "hu", langlabel: "匈牙利语"),
    LangItem(langValue: "vie", langlabel: "越南语")
  ];

  // 翻译结果文本框控制器（没这个还不知道怎么给TextField赋值？）
  final targetTextController = TextEditingController();
  // 源文本输入框控制器
  final sourceTextController = TextEditingController();

  // 翻译搜索引擎
  String translationEngine = "百度翻译";

  // 根据使用的引擎不同，语言缩写不同。此外显示对应列表
  List<LangItem> langLabels = [];

  // 选择的源语种和目标语种
  LangItem sourceLang = LangItem(langValue: "en", langlabel: "英语");
  LangItem targetLang = LangItem(langValue: "zh", langlabel: "中文");

  @override
  void initState() {
    super.initState();

    // 默认使用百度翻译引擎
    langLabels = baiduFanyiLangLabels;
  }

  @override
  void dispose() {
    targetTextController.dispose();
    super.dispose();
  }

  /// 根据选择的翻译引擎获取查询结果
  getTranslationResult() async {
    if (translationEngine == "自由翻译") {
      var transRst = await fetchLibreTranslateResult(sourceTextController.text,
          sourceLang.langValue, targetLang.langValue);
      setState(() {
        targetTextController.text = transRst["translatedText"];
      });
    } else if (translationEngine == "百度翻译") {
      var transRst = await fetchBaiduTranslateResult(sourceTextController.text,
          sourceLang.langValue, targetLang.langValue);
      setState(() {
        targetTextController.text = transRst.trans_result[0].dst;
      });
    }
  }

  /// 切换翻译引擎后，要重置显示引擎、语种代号、名称 .
  /// 又因为语种列表变化了，所以查询结果得清空，重新查询。
  /// 切换选中的语种为默认
  translationEngineChange() {
    setState(() {
      if (translationEngine == "百度翻译") {
        langLabels = baiduFanyiLangLabels;
      } else if (translationEngine == "自由翻译") {
        langLabels = libreTranslateLangLabels;
      }

      sourceLang = LangItem(langValue: "en", langlabel: "英语");
      targetLang = LangItem(langValue: "zh", langlabel: "中文");

      targetTextController.text = "";
      sourceTextController.text = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 1,
          child: Row(
            children: <Widget>[
              // 翻译引擎选择
              Expanded(
                flex: 3,
                child: DropdownButton<String>(
                  value: translationEngine,
                  elevation: 16,
                  style: const TextStyle(color: Colors.deepPurple),
                  underline: Container(
                    height: 3,
                    color: Colors.black,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      translationEngine = newValue!;
                      translationEngineChange();
                    });
                  },
                  items: translationEngineList
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
              Expanded(
                flex: 4,
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
                flex: 2,
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
                flex: 4,
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
        Expanded(
          flex: 1,
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
        Expanded(
          flex: 3,
          child: SizedBox(
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
              minLines: 6,
              maxLines: 6,
              controller: sourceTextController,
              onChanged: (text) {
                print('First text field: $text');
                // 如果有输入源文本，进行查询。
                if (text != "") {
                  getTranslationResult();
                } else {
                  // 如果清空了输入，翻译结果的内容也清空
                  setState(() {
                    targetTextController.text = "";
                  });
                }
              },
            ),
          ),
        ),
        // 间隔高度(预留文字转语音)
        Expanded(
          flex: 1,
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
          flex: 3,
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
