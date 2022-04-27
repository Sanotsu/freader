// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readhub_api_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadhubApiResult _$ReadhubApiResultFromJson(Map<String, dynamic> json) =>
    ReadhubApiResult(
      data: json['data'] == null
          ? null
          : ReadhubApiResultData.fromJson(json['data'] as Map<String, dynamic>),
      code: json['code'] as int?,
      message: json['message'] as int?,
    );

Map<String, dynamic> _$ReadhubApiResultToJson(ReadhubApiResult instance) =>
    <String, dynamic>{
      'data': instance.data?.toJson(),
      'code': instance.code,
      'message': instance.message,
    };

ReadhubApiResultData _$ReadhubApiResultDataFromJson(
        Map<String, dynamic> json) =>
    ReadhubApiResultData(
      totalItems: json['totalItems'] as int?,
      startIndex: json['startIndex'] as int?,
      pageIndex: json['pageIndex'] as int?,
      itemsPerPage: json['itemsPerPage'] as int?,
      currentItemCount: json['currentItemCount'] as int?,
      totalPages: json['totalPages'] as int?,
      items: (json['items'] as List<dynamic>?)
          ?.map((e) => ItemsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReadhubApiResultDataToJson(
        ReadhubApiResultData instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'startIndex': instance.startIndex,
      'pageIndex': instance.pageIndex,
      'itemsPerPage': instance.itemsPerPage,
      'currentItemCount': instance.currentItemCount,
      'totalPages': instance.totalPages,
      'items': instance.items?.map((e) => e.toJson()).toList(),
    };

ItemsData _$ItemsDataFromJson(Map<String, dynamic> json) => ItemsData(
      uid: json['uid'] as String?,
      title: json['title'] as String?,
      summary: json['summary'] as String?,
      siteNameDisplay: json['siteNameDisplay'] as String?,
      createdAt: json['createdAt'] as String?,
      url: json['url'] as String?,
      siteCount: json['siteCount'] as int?,
      newsAggList: (json['newsAggList'] as List<dynamic>?)
          ?.map((e) => NewsagglistData.fromJson(e as Map<String, dynamic>))
          .toList(),
      up: json['up'] as bool?,
      hasView: json['hasView'] as bool?,
      timelineId: json['timelineId'] as String?,
      entityList: json['entityList'] as List<dynamic>?,
      eventList: json['eventList'] as List<dynamic>?,
      tagList: (json['tagList'] as List<dynamic>?)
          ?.map((e) => TaglistData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ItemsDataToJson(ItemsData instance) => <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'summary': instance.summary,
      'siteNameDisplay': instance.siteNameDisplay,
      'createdAt': instance.createdAt,
      'url': instance.url,
      'siteCount': instance.siteCount,
      'newsAggList': instance.newsAggList?.map((e) => e.toJson()).toList(),
      'up': instance.up,
      'hasView': instance.hasView,
      'timelineId': instance.timelineId,
      'entityList': instance.entityList,
      'eventList': instance.eventList,
      'tagList': instance.tagList?.map((e) => e.toJson()).toList(),
    };

TaglistData _$TaglistDataFromJson(Map<String, dynamic> json) => TaglistData(
      uid: json['uid'] as String?,
      name: json['name'] as String?,
    );

Map<String, dynamic> _$TaglistDataToJson(TaglistData instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'name': instance.name,
    };

NewsagglistData _$NewsagglistDataFromJson(Map<String, dynamic> json) =>
    NewsagglistData(
      url: json['url'] as String?,
      title: json['title'] as String?,
      siteNameDisplay: json['siteNameDisplay'] as String?,
    );

Map<String, dynamic> _$NewsagglistDataToJson(NewsagglistData instance) =>
    <String, dynamic>{
      'url': instance.url,
      'title': instance.title,
      'siteNameDisplay': instance.siteNameDisplay,
    };
