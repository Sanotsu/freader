// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'readhub_api_common_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReadhubApiCommonResult _$ReadhubApiCommonResultFromJson(
        Map<String, dynamic> json) =>
    ReadhubApiCommonResult(
      data: ReadhubApiCommonResultData.fromJson(
          json['data'] as Map<String, dynamic>),
      code: json['code'] as int?,
      message: json['message'] as int?,
    );

Map<String, dynamic> _$ReadhubApiCommonResultToJson(
        ReadhubApiCommonResult instance) =>
    <String, dynamic>{
      'data': instance.data.toJson(),
      'code': instance.code,
      'message': instance.message,
    };

ReadhubApiCommonResultData _$ReadhubApiCommonResultDataFromJson(
        Map<String, dynamic> json) =>
    ReadhubApiCommonResultData(
      totalItems: json['totalItems'] as int,
      startIndex: json['startIndex'] as int,
      pageIndex: json['pageIndex'] as int,
      itemsPerPage: json['itemsPerPage'] as int,
      currentItemCount: json['currentItemCount'] as int,
      totalPages: json['totalPages'] as int,
      items: (json['items'] as List<dynamic>)
          .map((e) => ItemsData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ReadhubApiCommonResultDataToJson(
        ReadhubApiCommonResultData instance) =>
    <String, dynamic>{
      'totalItems': instance.totalItems,
      'startIndex': instance.startIndex,
      'pageIndex': instance.pageIndex,
      'itemsPerPage': instance.itemsPerPage,
      'currentItemCount': instance.currentItemCount,
      'totalPages': instance.totalPages,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

ItemsData _$ItemsDataFromJson(Map<String, dynamic> json) => ItemsData(
      uid: json['uid'] as String,
      title: json['title'] as String,
      summary: json['summary'] as String,
      url: json['url'] as String,
      siteNameDisplay: json['siteNameDisplay'] as String,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$ItemsDataToJson(ItemsData instance) => <String, dynamic>{
      'uid': instance.uid,
      'title': instance.title,
      'summary': instance.summary,
      'url': instance.url,
      'siteNameDisplay': instance.siteNameDisplay,
      'createdAt': instance.createdAt,
    };
