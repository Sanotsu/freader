import 'package:intl/intl.dart';
import 'package:json_annotation/json_annotation.dart';
part 'readhub_api_topic_detail.g.dart';

/// 所有属性都设为？，因为我也不知道什么时候api返回的对应字段就不存在了。也不是所有字段都有用到

@JsonSerializable(explicitToJson: true)
class ReadhubApiTopicDetail {
  ReadhubApiTopicDetailData data;
  int? code;
  int? message;
  ReadhubApiTopicDetail({required this.data, this.code, this.message});

  factory ReadhubApiTopicDetail.fromJson(Map<String, dynamic> json) =>
      _$ReadhubApiTopicDetailFromJson(json);
  Map<String, dynamic> toJson() => _$ReadhubApiTopicDetailToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReadhubApiTopicDetailData {
  String? id;
  List<EntityTopicsData>? entityTopics;
  List<NewsArrayData>? newsArray;
  String? createdAt;
  List<EntityEventTopicsData>? entityEventTopics;
  String? publishDate;
  String? summary;
  String? title;
  String? updatedAt;
  TimelineData? timeline;
  int? order;
  bool? hasInstantView;
  String? timelineId;
  List<TagsData>? tags;
  String? instantViewNewsId;

  ReadhubApiTopicDetailData({
    this.id,
    this.entityTopics,
    this.newsArray,
    this.createdAt,
    this.entityEventTopics,
    this.publishDate,
    this.summary,
    this.title,
    this.updatedAt,
    this.timeline,
    this.order,
    this.hasInstantView,
    this.timelineId,
    this.tags,
    this.instantViewNewsId,
  });

  factory ReadhubApiTopicDetailData.fromJson(Map<String, dynamic> json) =>
      _$ReadhubApiTopicDetailDataFromJson(json);
  Map<String, dynamic> toJson() => _$ReadhubApiTopicDetailDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TagsData {
  String? uid;
  String? name;

  TagsData({
    this.uid,
    this.name,
  });

  factory TagsData.fromJson(Map<String, dynamic> json) =>
      _$TagsDataFromJson(json);
  Map<String, dynamic> toJson() => _$TagsDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TimelineData {
  List<TopicsData>? topics;
  List<CommonEntitiesData>? commonEntities;
  String? id;

  TimelineData({
    this.topics,
    this.commonEntities,
    this.id,
  });

  factory TimelineData.fromJson(Map<String, dynamic> json) =>
      _$TimelineDataFromJson(json);
  Map<String, dynamic> toJson() => _$TimelineDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class CommonEntitiesData {
  int? id;
  String? topicId;
  String? nerName;
  int? weight;
  String? entityId;
  String? entityType;
  String? entityName;
  bool? isMain;
  ExtraData? extra;
  String? createdAt;
  String? updatedAt;
  bool? deleted;

  CommonEntitiesData({
    this.id,
    this.topicId,
    this.nerName,
    this.weight,
    this.entityId,
    this.entityType,
    this.entityName,
    this.isMain,
    this.extra,
    this.createdAt,
    this.updatedAt,
    this.deleted,
  });

  factory CommonEntitiesData.fromJson(Map<String, dynamic> json) =>
      _$CommonEntitiesDataFromJson(json);
  Map<String, dynamic> toJson() => _$CommonEntitiesDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ExtraData {
  FinanceData? finance;

  ExtraData({
    this.finance,
  });

  factory ExtraData.fromJson(Map<String, dynamic> json) =>
      _$ExtraDataFromJson(json);
  Map<String, dynamic> toJson() => _$ExtraDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class FinanceData {
  String? code;
  String? name;
  int? state;
  String? exchange;
  String? bussiness;

  FinanceData({
    this.code,
    this.name,
    this.state,
    this.exchange,
    this.bussiness,
  });

  factory FinanceData.fromJson(Map<String, dynamic> json) =>
      _$FinanceDataFromJson(json);
  Map<String, dynamic> toJson() => _$FinanceDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TopicsData {
  String? id;
  String? title;
  String? createdAt;

  TopicsData({
    this.id,
    this.title,
    this.createdAt,
  });

  factory TopicsData.fromJson(Map<String, dynamic> json) =>
      _$TopicsDataFromJson(json);
  Map<String, dynamic> toJson() => _$TopicsDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EntityEventTopicsData {
  String? entityId;
  String? entityName;
  String? entityType;
  int? eventType;
  String? eventTypeLabel;

  EntityEventTopicsData({
    this.entityId,
    this.entityName,
    this.entityType,
    this.eventType,
    this.eventTypeLabel,
  });

  factory EntityEventTopicsData.fromJson(Map<String, dynamic> json) =>
      _$EntityEventTopicsDataFromJson(json);
  Map<String, dynamic> toJson() => _$EntityEventTopicsDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NewsArrayData {
  String? id;
  String? url;
  String? title;
  String? siteName;
  String? mobileUrl;
  String? autherName;
  int? duplicateId;
  String? publishDate;
  String? language;
  bool? hasInstantView;
  int? statementType;

  NewsArrayData({
    this.id,
    this.url,
    this.title,
    this.siteName,
    this.mobileUrl,
    this.autherName,
    this.duplicateId,
    this.publishDate,
    this.language,
    this.hasInstantView,
    this.statementType,
  });

  getPublishDate() {
    // 获取创建时间，如果是utc，则加8个小时显示成北京时间
    var createdTime = DateTime.parse(publishDate ?? "");
    if (createdTime.isUtc) {
      createdTime = createdTime.add(const Duration(hours: 8));
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(createdTime);
  }

  factory NewsArrayData.fromJson(Map<String, dynamic> json) =>
      _$NewsArrayDataFromJson(json);
  Map<String, dynamic> toJson() => _$NewsArrayDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EntityTopicsData {
  String? nerName;
  String? entityId;
  String? entityName;
  String? entityType;
  EntityTopicsFinanceData? entityTopicsFinance;

  EntityTopicsData({
    this.nerName,
    this.entityId,
    this.entityName,
    this.entityType,
    this.entityTopicsFinance,
  });

  factory EntityTopicsData.fromJson(Map<String, dynamic> json) =>
      _$EntityTopicsDataFromJson(json);
  Map<String, dynamic> toJson() => _$EntityTopicsDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class EntityTopicsFinanceData {
  String? code;
  String? name;

  EntityTopicsFinanceData({
    this.code,
    this.name,
  });

  factory EntityTopicsFinanceData.fromJson(Map<String, dynamic> json) =>
      _$EntityTopicsFinanceDataFromJson(json);
  Map<String, dynamic> toJson() => _$EntityTopicsFinanceDataToJson(this);
}
