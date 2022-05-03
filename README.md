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
