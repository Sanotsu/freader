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
  - 数据库的设计有点问题。关于txt信息的本身 和用户txt阅读的进度之间的查询和关联，不太好，需要改进。
  - 每页显示的数量并不一致，有的最后一行不显示完整，有的只显示上面一半。毕竟不能填满。
  - 只测试了一本小说，其他几部还没弄，测试的输出还有很多。

- 后续可使用canvas的方法。目前可参考`lib\views\txt_viewer\text_composition`的内容
