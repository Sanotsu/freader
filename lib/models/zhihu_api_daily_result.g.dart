// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'zhihu_api_daily_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ZhihuApiDailyResult _$ZhihuApiDailyResultFromJson(Map<String, dynamic> json) =>
    ZhihuApiDailyResult(
      date: json['date'] as String,
      stories: (json['stories'] as List<dynamic>)
          .map((e) => StoriesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ZhihuApiDailyResultToJson(
        ZhihuApiDailyResult instance) =>
    <String, dynamic>{
      'date': instance.date,
      'stories': instance.stories.map((e) => e.toJson()).toList(),
    };

StoriesData _$StoriesDataFromJson(Map<String, dynamic> json) => StoriesData(
      image_hue: json['image_hue'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      hint: json['hint'] as String,
      ga_prefix: json['ga_prefix'] as String,
      images:
          (json['images'] as List<dynamic>).map((e) => e as String).toList(),
      type: json['type'] as int,
      id: json['id'] as int,
    );

Map<String, dynamic> _$StoriesDataToJson(StoriesData instance) =>
    <String, dynamic>{
      'image_hue': instance.image_hue,
      'title': instance.title,
      'url': instance.url,
      'hint': instance.hint,
      'ga_prefix': instance.ga_prefix,
      'images': instance.images,
      'type': instance.type,
      'id': instance.id,
    };
