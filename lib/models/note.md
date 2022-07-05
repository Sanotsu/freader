目前(2022-04-20)根据已有 json 文件生成 model 的方法是：

1. 添加依赖`json_serializable: ^6.1.6`和 dev 依赖`build_runner: ^2.1.10`
2. 到网站`https://czero1995.github.io/json-to-model/`,复制 json 文件转成的类文件。
   - 修改里面的报错信息，例如：类名不是全大写、所有都是必填属性、不是 null 安全等。
3. 在项目根目录运行 `flutter pub run build_runner build`。

更多 json to model 查看官方教程[JSON 和序列化数据](https://flutter.cn/docs/development/data-and-backend/json)

2022-05-11

`app_embedded`文件夹下的 model 是 app 内部逻辑的一些类，就不是那些 api 返回的 json 转化的 model 了，  
一般是内部持久化逻辑的东西。例如`pdf viewer`存放所有的 pdf 文件列表，及其对应阅读记录？

2022-07-04 

单独直接转为class的[JSON to Dart null safety](https://www.webinovers.com/web-tools/json-to-dart-convertor)
---

## readhub 相关 model 和 url 说明

### 旧的接口 2022-04-26

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

---

### readhub api 说明（2022-04-27 时自行整理）：

**一：分类的数据请求:**  
热门话题：`https://api.readhub.cn/topic/list?page=2&size=10`  
其他类别：`https://api.readhub.cn/news/list?size=10&type=2&page=1`

其中 type 的值：  
**0 或者 1 科技动态  
2 技术资讯  
3 区块链 blockchain  
经过测试，4 5 也有数据，但不清楚是什么分类。**

因为 url 都一样，返回结构一致，除了 topics 热门资讯外。

其实最好的，还是把所有的 api 返回的数据中通用数据整理成一个公用的 model。

~~所以，现在(2022-04-26)readhub api 返回结构有两个 model:~~

- ~~-`热门话题`：`ReadhubApiTopicsResult`~~
- ~~-`科技动态`与`技术资讯`：`ReadhubApiCommonResult`~~

2022-04-27：  
已经合并为一个 model: `ReadhubApiResult`

---

**二：热门话题的详情：**  
`https://api.readhub.cn/topic/xxxxxx`

其中最后的 xxxxxx 为【热门话题】的 topicId。  
示例：`https://api.readhub.cn/topic/8fxcBjoRnWX`

注意：如果 xxxx 不是【热门话题】的 topicId，返回结果则为`{}`。  
例如：`https://api.readhub.cn/topic/8fybjJpVpxi`

详情中个人感兴趣的有`事件追踪`，数据结构有变化，所以单独 model：`ReadhubApiTopicDetail`。

---

**三：检查是否有更新：**

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

---

**四：关键字搜索**

`https://search.readhub.cn/api/entity/news?page=1&size=20&query=xxxxx&type=hot`

参数说明：

- page: 页数, 拉取到的数据中可以看到 totalPages
- size：一次请求拉取的话题数目
- query: 关键字, 就是搜索的内容
- type: hot,热门话题, 还有一个 all, 我舍弃掉了

---

## 一言 （hitokoto） 相关 model 和 url 说明

[一言开发者中心官方文档](https://developer.hitokoto.cn/sentence/)

### 请求地址

| 地址                         | 协议  | 方法 | QPS | 限制 | 线路 |
|------------------------------|-------|------|-----|------|------|
| v1.hitokoto.cn               | HTTPS | Any  | 3.5 | 全球 |      |
| international.v1.hitokoto.cn | HTTPS | Any  | 10  | 国外 |      |

常用 url 示例 : `https://v1.hitokoto.cn/?c=k&c=i&c=d`

### 句子类型（参数）

- a 动画
- b 漫画
- c 游戏
- d 文学
- e 原创
- f 来自网络
- g 其他
- h 影视
- i 诗词
- j 网易云
- k 哲学
- l 抖机灵
- 其他 作为 动画 类型处理

返回结构，在 jsons 文件夹下：

- hitokoto_result.json

---

## pexels api 说明

[pexels api 官方文档](https://www.pexels.com/zh-cn/api/documentation/)

**注意：需要先注冊账号，获取 API key ，每次请求都要在 header 的 `Authorization`中带上。**

**(By default, the API is rate-limited to 200 requests per hour and 20,000 requests per month. )**

### 图片请求地址

- 1 搜索 `GET https://api.pexels.com/v1/search`
  - 参数
    - `query` string | required
      - The search query. Ocean, Tigers, Pears, etc.
    - `orientation` string | optional
      - Desired photo orientation. The current supported orientations are: landscape, portrait or square.
    - `size` string | optional
      - Minimum photo size. The current supported sizes are: large(24MP), medium(12MP) or small(4MP).
    - `color` string | optional
      - Desired photo color. Supported colors: red, orange, yellow, green, turquoise, blue, violet, pink, brown, black, gray, white or any hexidecimal color code (eg. #ffffff).
    - `locale` string | optional
      - The locale of the search you are performing. The current supported locales are: 'en-US' 'pt-BR' 'es-ES' 'ca-ES' 'de-DE' 'it-IT' 'fr-FR' 'sv-SE' 'id-ID' 'pl-PL' 'ja-JP' 'zh-TW' 'zh-CN' 'ko-KR' 'th-TH' 'nl-NL' 'hu-HU' 'vi-VN' 'cs-CZ' 'da-DK' 'fi-FI' 'uk-UA' 'el-GR' 'ro-RO' 'nb-NO' 'sk-SK' 'tr-TR' 'ru-RU'.
    - `page` integer | optional
      - The page number you are requesting. Default: 1
    - `per_page` integer | optional
      - The number of results you are requesting per page. Default: 15 Max: 80
  - 响应
    - `photos` array of Photo
      - An array of Photo objects.
    - `page` integer
      - The current page number.
    - `per_page` integer
      - The number of results returned with each page.
    - `total_results` integer
      - The total number of results for the request.
    - `prev_page` string | optional
      - URL for the previous page of results, if applicable.
    - `next_page` string | optional
      - URL for the next page of results, if applicable.
- 2 获取指定图片详情 `GET https://api.pexels.com/v1/photos/:id` 通过其 ID 检索特定的 Photo。

  - 参数
    - `id` integer | required
      - The id of the photo you are requesting.
  - 响应
    - Returns a Photo object

- 3 获取编辑精选图片 `GET https://api.pexels.com/v1/curated?page=1&per_page=80` Pexels 团队精心挑选的实时图片。每小时至少添加一张新图片。
  - 参数
    - `page` integer | optional
      - The page number you are requesting. Default: 1
    - `per_page` integer | optional
      - The number of results you are requesting per page. Default: 15 Max: 80
  - 响应
    - 和`1 搜索`接口一致。

示例：一次查询中国地区的“cat”的 80 张图片。（尽可能多，然后本地缓存数据，因为 api 请求有限制。）

`https://api.pexels.com/v1/search/?page=1&per_page=80&query=cat&locale=zh-CN`

### 请求统计数据

你可以根据 Pexels API 返回的成功请求查看每月配额还剩多少请求，它们包含三个 HTTP 标头：

```
Response Header	        Meaning
X-Ratelimit-Limit	      你的月度总请求限额
X-Ratelimit-Remaining	  还剩多少请求
X-Ratelimit-Reset	      当前月翻转的UNIX时间戳
```

注意: 这些响应标头只在(2xx)成功响应下返回。它们不随其他响应返回，包括 429 Too Many Requests，后者指示你超出速率限制。

请确保跟踪 X-Ratelimit-Remaining 和 X-Ratelimit-Reset 以免超出请求限额。

温馨提示：图片注意带上作者和网站标志。统计數量可能有延迟。不要滥用 Pexels API。

返回结构，在 jsons 文件夹下：

- pexels_api_image_curated.json
- pexels_api_image.json

---

## 知乎日报 api 说明

[別人收集的接口地址](https://gist.github.com/ameizi/f3f320a512030292362d)

简单对比发现，最新的日报，也可以直接输入 【**该天日期+1**】 进行查询，这样和历史日期的日报，在返回的 json 格式上就一致了。

### 日报请求地址

- `GET https://news-at.zhihu.com/api/3/news/before/<当天日期+1>`
  - 其中`<当天日期+1>`形式为 `YYYYMMDD`.
    - 假如今天为`20220506`，明天为`20220507`，要看今天的日报，输入`20220507`甚至之后的日期都行；
    - 同理，要查看`2022-05-04`的日报，就要传入`20220505`。注意 before 的含义。

返回结构，在 jsons 文件夹下：

- zhihu_daily_result.json
