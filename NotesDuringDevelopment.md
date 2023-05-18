# freader

A new Flutter project.

## Getting Started

项目结构：

```
│  main.dart    入口
├─common        一些工具类，如通用方法类、网络接口类、保存全局变量的静态类等
│  ├─config
│  └─utils
├─demos
├─i18n          国际化相关的类都在此目录下
├─layout        页面布局（一般都是sidebar navbar main，但工具框架好像有）
├─models        Json文件对应的Dart Model类会在此目录下
├─routes        存放所有路由页面类
├─states        保存APP中需要跨组件共享的状态类
├─views         页面
│  ├─image_view       开源图片tab
│  ├─markdown_view    科技博文tab
│  ├─news_view        各式新闻tab
│  ├─pdf_view         pdf阅读器tab
│  ├─tools_view       实用工具tab
│  └─txt_view         内置小说tab
└─widgets       APP内封装的一些Widget组件都在该目录下
```

## 思路记录

一些思路记录，免得以后忘记了

### 模块分类层级

目前是 第一层`HomePage` 就开始使用`TabBarView`；  
到第二层`NewsPage`模块已经`TabBarView`；  
到具体第三层`ReadhubPage`的分类，依旧是`TabBarView`。

后续可使用其他方式。

### 上拉加载，下拉刷新

刷新是使用`RefreshIndicator`，里面嵌了个`FutureBuilder`去渲染了`ListView`。

加载是 `ScrollController`检测 list 拉到了最后。

### readhub 热门话题详情弹窗。

使用了 2 个 dialog，点击`link`图标是使用`showModalBottomSheet`，点击`detail`图标使用的`showDialog`。

### 新闻收藏夹的思路（not done）

各个模块（到第三层）分別一个类，存放收藏的新闻 uid 和 url。构建一个 ListView 去显示。

因为没有账号之类的，所以状态放在本地。不使用数据库的话，可能就是`shared_preferences`。要本地数据库的话，可能是`sqflite`.要文件读写，`path_provider`

事实上，使用`Provider`管理全局贡献状态都沒搞懂(2022-04-29)，只是投机直接取本地数据去在 widget 加载时构建显示。

### pexels 图片展示和浏览（not yet）

qps 有限制，每次请求 80 条，慢慢展示。

一次搜索请求后，要求等待 30s 才能重新请求。怎么记录两次请求间隔？

浏览图片有不同的尺寸，太大了很耗流量，是不是有预览和详细操作（放大、下载等）。

### 顶部搜索框的区分（not yet）

考虑有一个全局状态，记录现在激活的页面时那一個，这样对应服务进行数据查询和渲染。

打包 apk 命令:`flutter build apk --split-per-abi`

---

## 重构 layout 思路

```
|----------layout---------|------views------|------widget------
app
    home_page                                       DefaultTabController->Scaffold
        image_page                                     ListView
                            pexels_image_page              Scaffold
                            image_page_demo                Scaffold
        news_page                                      ListView
                            readhub_page                   Scaffold
                            news_page_demo                 Scaffold

```

## txt reader

- 目前仅考虑内嵌文本
- 先分章节把文本內容存入 db
  - txt_data_info?
- 读取每章文字数量，使用 pageView 分页显示
  - 毎章多少字、一页显示多少字、一章多少页，存入 db
    - txt_data_info?
- 用户滚动到第几章第几页，在退出阅读頁面时保存到 db
  - 计算已读的页数和总页数，计算大概的進度
    - user_txt_state?
- 因为调整显示文字大小會改變页数，會影響数据库數據，暂时不让改
- 書簽关联页码等，先不弄跳轉，只是读取数据库中章节信息而已

實現主要参考`lib\_demos\multi_list_text_demo.dart`，后续可能加上分页指示器，例如`https://pub.dev/packages/dots_indicator`

或者[loop_page_view](https://pub.dev/packages/loop_page_view)

2022-06-04 txt reader 要改进点:

- 关于使用 pageview 用章节总数/每页显示数量=章节数量 这个设计:

  - 数据库的设计有点问题。关于 txt 信息的本身 和用户 txt 阅读的进度之间的查询和关联，不太好，需要改进。
  - 每页显示的数量并不一致，有的最后一行不显示完整，有的只显示上面一半。毕竟不能填满。
  - 只测试了一本小说，其他几部还没弄，测试的输出还有很多。

- 后续可使用 canvas 的方法。目前可参考`lib\views\txt_viewer\text_composition`的内容

pdf 和 txt 中删除 db 再重建好像有点问题，不是这么搞的。
加载 txt 章节时，没有转圈圈提示

# 2023-03-31 更新依赖到当前最新

此时 flutter sdk 为 3.7.8，相关依赖也是最新，但有几个问题：

- 1 md 阅读器不能正常显示
  - 一些组件使用方法的更新，修复报错信息就正常能用了
- 2 音频播放使用获取音频信息的依赖自身报错，整个组件更换工具库的话需要重写。

**考虑本地音乐播放器单独做一个 app，这个原本的 tool 其实也很不完善，也很多问题**

**2023-05-17 取消音频播放模块功能，构建单独的项目 freader_musci_player**

---

- 大量的`Don't use 'BuildContext's across async gaps.Try rewriting the code to not reference the 'BuildContext'`警告。
  [参看](https://stackoverflow.com/questions/68871880/do-not-use-buildcontexts-across-async-gaps)

## 更新 Android Gradle 遇到的一些问题

- 出现很多类似警告：`Warning: Mapping new ns http://schemas.android.com/repository/android/common/02 to old ns http://schemas.android.com/repository/android/common/01`

- 出现类似错误信息:

```
Warning: Mapping new ns http://schemas.android.com/repository/android/common/02 to old ns http://schemas.android.com/repository/android/common/01
Warning: Mapping new ns http://schemas.android.com/repository/android/generic/02 to old ns http://schemas.android.com/repository/android/generic/01
Warning: Mapping new ns http://schemas.android.com/sdk/android/repo/addon2/02 to old ns http://schemas.android.com/sdk/android/repo/addon2/01
```

是因为 gradle 版本太旧了，需要升级一下，虽然我也没有用最新版。[参看](https://stackoverflow.com/questions/68600352/build-warning-mapping-new-ns-to-old-ns)

**要特别注意 jdk 和 maven 的 gradle 以及 android gradle 版本的对应关系。**

2023-05-17 更新本项目对应是 ：`jdk 11.0.18  - AGP 7.4.2 - gradle 7.6`，参看[更新 Gradle](https://developer.android.google.cn/studio/releases/gradle-plugin?hl=zh-cn)

修改`android/build.gradle`文件

```s
buildscript {
    repositories {
        google()
        mavenCentral()
    }

    dependencies {
        classpath 'com.android.tools.build:gradle:7.4.2' # Update this line,我之前是4.1.0
        ...
    }
}
```

和`android/gradle/wrapper/gradle-wrapper.properties`文件

```s
distributionUrl=https\://services.gradle.org/distributions/gradle-7.6-all.zip # Update this line 我之前是6.7
```

注意，更新之后可能出现类似错误:

```sh
Using insecure protocols with repositories, without explicit opt-in, is unsupported. Switch Maven repository 'maven3(http://maven.aliyun.com/nexus/content/groups/public)' to redirect to a secure protocol (like HTTPS) or allow insecure protocols.
```

这应该是修改了默认 maven 仓库地址，需要修改`android/build.gradle`文件中自定义的 maven 地址，忽略不安全协议：

```s
# 之前:
maven {
    url 'https://maven.aliyun.com/repository/google'
}
# 改为:
maven {
    allowInsecureProtocol = true
    url 'https://maven.aliyun.com/repository/google'
}
```

**注意，慎重直接修改到最新版本，可能出现兼容问题**，类似：

```sh
Android Gradle plugin requires Java 17 to run. You are currently using Java 11.
[        ]       Your current JDK is located in /home/david/.jdks/temurin-11.0.18
```

这是因为我的 jdk 是 11 版本，直接使用的`com.android.tools.build:gradle:8.0.1`时就报错了，因为它[最低要求 jdk17](https://developer.android.com/build/releases/gradle-plugin#jdk-17-agp)，所以又改回来了。

**注意，升级 AGP 也要注意插件的兼容性。**
例如 AGP cc 升级到 7.4.2，`image_gallery_saver: ^1.7.1` 需要`org.jetbrains.kotlin:kotlin-gradle-plugin:1.3.72`这个版本，但前者只支持`1.5.20`或更高。
这就导致要么降级，要么升级插件。如果插件本身就很久没更新了，那就得重写功能业务代码了。

在本项目，还有一个`gallery_saver: ^2.3.2`插件也是保存图片到本地，虽然升级之后还可以用，为了统一做法，也取消掉。

两个插件都是保存在`/storage/emulated/0/Pictures/`目录下。但上次更新都在 2021 年 10 月份，比较久远。

**如果继续出现类似错误**:

```sh
 Script '/home/david/SOFT/flutter/packages/flutter_tools/gradle/flutter.gradle' line: 1151
[        ] * What went wrong:
[        ] Execution failed for task ':app:compileFlutterBuildDebug'.
[        ] > Process 'command '/home/david/SOFT/flutter/bin/flutter'' finished with non-zero exit value 1
[        ] * Try:
[        ] > Run with --debug option to get more log output.
[        ] > Run with --scan to get full insights.
[        ] * Exception is:
[        ] org.gradle.api.tasks.TaskExecutionException: Execution failed for task ':app:compileFlutterBuildDebug'.
[        ]      at org.gradle.api.internal.tasks.execution.ExecuteActionsTaskExecuter.lambda$executeIfValid$1(ExecuteActionsTaskExecuter.java:142)
[        ]      at org.gradle.internal.Try$Failure.ifSuccessfulOrElse(Try.java:282)
```

则更新一下依赖:

```sh
flutter clean
flutter pub get
```
