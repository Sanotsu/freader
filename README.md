# freader

看一些聚合新闻，看一点内置文学。

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

