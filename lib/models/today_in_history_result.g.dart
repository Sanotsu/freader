// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'today_in_history_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodayInHistoryResult _$TodayInHistoryResultFromJson(
        Map<String, dynamic> json) =>
    TodayInHistoryResult(
      data: (json['data'] as List<dynamic>)
          .map((e) =>
              TodayInHistoryResultData.fromJson(e as Map<String, dynamic>))
          .toList(),
      code: json['code'] as int,
      month: json['month'] as String,
      day: json['day'] as String,
    );

Map<String, dynamic> _$TodayInHistoryResultToJson(
        TodayInHistoryResult instance) =>
    <String, dynamic>{
      'data': instance.data.map((e) => e.toJson()).toList(),
      'code': instance.code,
      'month': instance.month,
      'day': instance.day,
    };

TodayInHistoryResultData _$TodayInHistoryResultDataFromJson(
        Map<String, dynamic> json) =>
    TodayInHistoryResultData(
      year: json['year'] as int?,
      title: json['title'] as String,
      link: json['link'] as String,
      type: json['type'] as String,
    );

Map<String, dynamic> _$TodayInHistoryResultDataToJson(
        TodayInHistoryResultData instance) =>
    <String, dynamic>{
      'year': instance.year,
      'title': instance.title,
      'link': instance.link,
      'type': instance.type,
    };
