// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readhub_api_topic_detail.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadhubApiTopicDetail _$ReadhubApiTopicDetailFromJson(
        Map<String, dynamic> json) =>
    ReadhubApiTopicDetail(
      data: ReadhubApiTopicDetailData.fromJson(
          json['data'] as Map<String, dynamic>),
      code: json['code'] as int?,
      message: json['message'] as int?,
    );

Map<String, dynamic> _$ReadhubApiTopicDetailToJson(
        ReadhubApiTopicDetail instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'code': instance.code,
      'message': instance.message,
    };

ReadhubApiTopicDetailData _$ReadhubApiTopicDetailDataFromJson(
        Map<String, dynamic> json) =>
    ReadhubApiTopicDetailData(
      id: json['id'] as String?,
      entityTopics: (json['entityTopics'] as List<dynamic>?)
          ?.map((e) => EntityTopicsData.fromJson(e as Map<String, dynamic>))
          .toList(),
      newsArray: (json['newsArray'] as List<dynamic>?)
          ?.map((e) => NewsArrayData.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: json['createdAt'] as String?,
      entityEventTopics: (json['entityEventTopics'] as List<dynamic>?)
          ?.map(
              (e) => EntityEventTopicsData.fromJson(e as Map<String, dynamic>))
          .toList(),
      publishDate: json['publishDate'] as String?,
      summary: json['summary'] as String?,
      title: json['title'] as String?,
      updatedAt: json['updatedAt'] as String?,
      timeline: json['timeline'] == null
          ? null
          : TimelineData.fromJson(json['timeline'] as Map<String, dynamic>),
      order: json['order'] as int?,
      hasInstantView: json['hasInstantView'] as bool?,
      timelineId: json['timelineId'] as String?,
      tags: (json['tags'] as List<dynamic>?)
          ?.map((e) => TagsData.fromJson(e as Map<String, dynamic>))
          .toList(),
      instantViewNewsId: json['instantViewNewsId'] as String?,
    );

Map<String, dynamic> _$ReadhubApiTopicDetailDataToJson(
        ReadhubApiTopicDetailData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityTopics': instance.entityTopics?.map((e) => e.toJson()).toList(),
      'newsArray': instance.newsArray?.map((e) => e.toJson()).toList(),
      'createdAt': instance.createdAt,
      'entityEventTopics':
          instance.entityEventTopics?.map((e) => e.toJson()).toList(),
      'publishDate': instance.publishDate,
      'summary': instance.summary,
      'title': instance.title,
      'updatedAt': instance.updatedAt,
      'timeline': instance.timeline?.toJson(),
      'order': instance.order,
      'hasInstantView': instance.hasInstantView,
      'timelineId': instance.timelineId,
      'tags': instance.tags?.map((e) => e.toJson()).toList(),
      'instantViewNewsId': instance.instantViewNewsId,
    };

TagsData _$TagsDataFromJson(Map<String, dynamic> json) => TagsData(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$TagsDataToJson(TagsData instance) => <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
    };

TimelineData _$TimelineDataFromJson(Map<String, dynamic> json) => TimelineData(
      topics: (json['topics'] as List<dynamic>?)
          ?.map((e) => TopicsData.fromJson(e as Map<String, dynamic>))
          .toList(),
      commonEntities: (json['commonEntities'] as List<dynamic>?)
          ?.map((e) => CommonEntitiesData.fromJson(e as Map<String, dynamic>))
          .toList(),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$TimelineDataToJson(TimelineData instance) =>
    <String, dynamic>{
      'topics': instance.topics?.map((e) => e.toJson()).toList(),
      'commonEntities':
          instance.commonEntities?.map((e) => e.toJson()).toList(),
      'id': instance.id,
    };

CommonEntitiesData _$CommonEntitiesDataFromJson(Map<String, dynamic> json) =>
    CommonEntitiesData(
      id: json['id'] as int?,
      topicId: json['topicId'] as String?,
      nerName: json['nerName'] as String?,
      weight: json['weight'] as int?,
      entityId: json['entityId'] as String?,
      entityType: json['entityType'] as String?,
      entityName: json['entityName'] as String?,
      isMain: json['isMain'] as bool?,
      extra: json['extra'] == null
          ? null
          : ExtraData.fromJson(json['extra'] as Map<String, dynamic>),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      deleted: json['deleted'] as bool?,
    );

Map<String, dynamic> _$CommonEntitiesDataToJson(CommonEntitiesData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'topicId': instance.topicId,
      'nerName': instance.nerName,
      'weight': instance.weight,
      'entityId': instance.entityId,
      'entityType': instance.entityType,
      'entityName': instance.entityName,
      'isMain': instance.isMain,
      'extra': instance.extra?.toJson(),
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
      'deleted': instance.deleted,
    };

ExtraData _$ExtraDataFromJson(Map<String, dynamic> json) => ExtraData(
      finance: json['finance'] == null
          ? null
          : FinanceData.fromJson(json['finance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$ExtraDataToJson(ExtraData instance) => <String, dynamic>{
      'finance': instance.finance?.toJson(),
    };

FinanceData _$FinanceDataFromJson(Map<String, dynamic> json) => FinanceData(
      code: json['code'] as String?,
      name: json['name'] as String?,
      state: json['state'] as int?,
      exchange: json['exchange'] as String?,
      bussiness: json['bussiness'] as String?,
    );

Map<String, dynamic> _$FinanceDataToJson(FinanceData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
      'state': instance.state,
      'exchange': instance.exchange,
      'bussiness': instance.bussiness,
    };

TopicsData _$TopicsDataFromJson(Map<String, dynamic> json) => TopicsData(
      id: json['id'] as String?,
      title: json['title'] as String?,
      createdAt: json['createdAt'] as String?,
    );

Map<String, dynamic> _$TopicsDataToJson(TopicsData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'createdAt': instance.createdAt,
    };

EntityEventTopicsData _$EntityEventTopicsDataFromJson(
        Map<String, dynamic> json) =>
    EntityEventTopicsData(
      entityId: json['entityId'] as String?,
      entityName: json['entityName'] as String?,
      entityType: json['entityType'] as String?,
      eventType: json['eventType'] as int?,
      eventTypeLabel: json['eventTypeLabel'] as String?,
    );

Map<String, dynamic> _$EntityEventTopicsDataToJson(
        EntityEventTopicsData instance) =>
    <String, dynamic>{
      'entityId': instance.entityId,
      'entityName': instance.entityName,
      'entityType': instance.entityType,
      'eventType': instance.eventType,
      'eventTypeLabel': instance.eventTypeLabel,
    };

NewsArrayData _$NewsArrayDataFromJson(Map<String, dynamic> json) =>
    NewsArrayData(
      id: json['id'] as String?,
      url: json['url'] as String?,
      title: json['title'] as String?,
      siteName: json['siteName'] as String?,
      mobileUrl: json['mobileUrl'] as String?,
      autherName: json['autherName'] as String?,
      duplicateId: json['duplicateId'] as int?,
      publishDate: json['publishDate'] as String?,
      language: json['language'] as String?,
      hasInstantView: json['hasInstantView'] as bool?,
      statementType: json['statementType'] as int?,
    );

Map<String, dynamic> _$NewsArrayDataToJson(NewsArrayData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'url': instance.url,
      'title': instance.title,
      'siteName': instance.siteName,
      'mobileUrl': instance.mobileUrl,
      'autherName': instance.autherName,
      'duplicateId': instance.duplicateId,
      'publishDate': instance.publishDate,
      'language': instance.language,
      'hasInstantView': instance.hasInstantView,
      'statementType': instance.statementType,
    };

EntityTopicsData _$EntityTopicsDataFromJson(Map<String, dynamic> json) =>
    EntityTopicsData(
      nerName: json['nerName'] as String?,
      entityId: json['entityId'] as String?,
      entityName: json['entityName'] as String?,
      entityType: json['entityType'] as String?,
      entityTopicsFinance: json['entityTopicsFinance'] == null
          ? null
          : EntityTopicsFinanceData.fromJson(
              json['entityTopicsFinance'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$EntityTopicsDataToJson(EntityTopicsData instance) =>
    <String, dynamic>{
      'nerName': instance.nerName,
      'entityId': instance.entityId,
      'entityName': instance.entityName,
      'entityType': instance.entityType,
      'entityTopicsFinance': instance.entityTopicsFinance?.toJson(),
    };

EntityTopicsFinanceData _$EntityTopicsFinanceDataFromJson(
        Map<String, dynamic> json) =>
    EntityTopicsFinanceData(
      code: json['code'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$EntityTopicsFinanceDataToJson(
        EntityTopicsFinanceData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'name': instance.name,
    };
