目前(2022-04-20)根据已有 json 文件生成 model 的方法是：

1. 添加依赖`json_serializable: ^6.1.6`和 dev 依赖`build_runner: ^2.1.10`
2. 到网站`https://czero1995.github.io/json-to-model/`,复制 json 文件转成的类文件。
   - 修改里面的报错信息，例如：类名不是全大写、所有都是必填属性、不是 null 安全等。
3. 在项目根目录运行 `flutter pub run build_runner build`。

更多 json to model 查看官方教程[JSON 和序列化数据](https://flutter.cn/docs/development/data-and-backend/json)

## 注意事项

### 2022-04-26

readhub api 几个分类返回的结构还不一致，之前并未注意。

关于旧的接口，可參考別的介绍：[简单介绍一下 API](https://github.com/wxpcl123/readhub#%E7%AE%80%E5%8D%95%E4%BB%8B%E7%BB%8D%E4%B8%80%E4%B8%8Bapi)

~~例如(旧)技术资讯的 url 和参数： `https://api.readhub.cn/technews?pageSize=10&lastCursor=1650837433000`~~

~~其中**参数中 lastCursor** 为上一次的時間戳，~~

~~没有直接分页的 pageNumber 标志的时候，需要自行记录上一次的時間戳是多久，在此基础上查询指定數量。~~

~~例如 要查询`2022-04-26 08:00:00` 之前的 10 条数据，则需要：~~

1. ~~`2022-04-26 08:00:00` 的時間戳为 `1650931200000`,为当前 lastCursor 的值。~~
2. ~~发起请求：`https://api.readhub.cn/technews?pageSize=10&lastCursor=1650931200000`，获取到数据 list。~~
3. ~~更新 lastCursor 的值为 list 中最后一条数据的`"publishDate": "2022-04-25T19:34:17.000Z"`的時間戳。~~
4. ~~下一个 10 条，lastCursor 的值为上一步 publishDate 转换的時間戳。~~
5. ~~ 如果是查询第一页，则不传 lastCursor 参数，但第二页就需要带上第一个最后一条 publishDate 的转化時間戳值。~~
6. ~~**现在参数名为 publishDate，后续不一定还是一样。**~~

在 jsons 文件夹下各自区别：

- readhub_api_topics_result.json
  - 标识和分类： topics 热门话题
  - url 和参数： https://api.readhub.cn/topic/list?page=2&size=10
- readhub_api_tech_result.json
  - 标识和分类： tech 技术资讯
  - url 和参数： https://api.readhub.cn/news/list?size=10&type=2&page=1
- readhub_api_news_result.json
  - 标识和分类： news 科技动态
  - url 和参数： https://api.readhub.cn/news/list?size=10&type=1&page=1
- readhub_api_daily_result.json（无）
  - 标识和分类： daily 每日早报
  - url 和参数： 不详

api url 中`https://api.readhub.cn/news/list?size=10&type=2&page=1`中的 type:  
**1 科技动态  
2 技术资讯  
3 区块链 blockchain  
经过测试，0 4 5 也有数据，但不清楚是什么分类。**

因为 url 都一样，返回结构一致，除了 topics 热门资讯外。

其实最好的，还是把所有的 api 返回的数据中通用数据整理成一个公用的 model。

**检查是否有更新：**

`https://api.readhub.cn/topic/list/update_check?last_topic_id=8fwLwlcAGSj`  
其中`last_topic_id`为目前最新的文章 uid。

如果有更新，返回结构：

```json
{
  "data": {
    "items": [{ "count": 1 }]
  }
}
```

没有更新，count 为 0.

~~所以，现在(2022-04-26)readhub api 返回结构有两个 model:~~

- ~~-`热门话题`：`ReadhubApiTopicsResult`~~
- ~~-`科技动态`与`技术资讯`：`ReadhubApiCommonResult`~~

2022-04-27：  
已经合并为一个 model: `ReadhubApiResult`

---
