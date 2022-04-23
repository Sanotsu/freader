目前(2022-04-20)根据已有 json 文件生成 model 的方法是：

1. 添加依赖`json_serializable: ^6.1.6`和 dev 依赖`build_runner: ^2.1.10`
2. 到网站`https://czero1995.github.io/json-to-model/`,复制 json 文件转成的类文件。
   - 修改里面的报错信息，例如：类名不是全大写、所有都是必填属性、不是 null 安全等。
3. 在项目根目录运行 `flutter pub run build_runner build`。

更多 json to model 查看官方教程[JSON 和序列化数据](https://flutter.cn/docs/development/data-and-backend/json)
