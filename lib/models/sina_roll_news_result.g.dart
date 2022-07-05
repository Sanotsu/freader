// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sina_roll_news_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SinaRollNewsResult _$SinaRollNewsResultFromJson(Map<String, dynamic> json) =>
    SinaRollNewsResult(
      data: json['data'] == null
          ? null
          : SinaRollNewsResultData.fromJson(
              json['data'] as Map<String, dynamic>),
      code: json['code'] as int?,
      message: json['message'] as int?,
    );

Map<String, dynamic> _$SinaRollNewsResultToJson(SinaRollNewsResult instance) =>
    <String, dynamic>{
      'data': instance.data?.toJson(),
      'code': instance.code,
      'message': instance.message,
    };

SinaRollNewsResultData _$SinaRollNewsResultDataFromJson(
        Map<String, dynamic> json) =>
    SinaRollNewsResultData(
      result: json['result'] == null
          ? null
          : ResultData.fromJson(json['result'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SinaRollNewsResultDataToJson(
        SinaRollNewsResultData instance) =>
    <String, dynamic>{
      'result': instance.result?.toJson(),
    };

ResultData _$ResultDataFromJson(Map<String, dynamic> json) => ResultData(
      status: json['status'] == null
          ? null
          : StatusData.fromJson(json['status'] as Map<String, dynamic>),
      timestamp: json['timestamp'] as String?,
      data: (json['data'] as List<dynamic>?)
          ?.map((e) => DataData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ResultDataToJson(ResultData instance) =>
    <String, dynamic>{
      'status': instance.status?.toJson(),
      'timestamp': instance.timestamp,
      'data': instance.data?.map((e) => e.toJson()).toList(),
    };

DataData _$DataDataFromJson(Map<String, dynamic> json) => DataData(
      intime: json['intime'] as String?,
      ctime: json['ctime'] as String?,
      mtime: json['mtime'] as String?,
      docid: json['docid'] as String?,
      url: json['url'] as String?,
      urls: json['urls'] as String?,
      wapurl: json['wapurl'] as String?,
      wapurls: json['wapurls'] as String?,
      title: json['title'] as String?,
      intro: json['intro'] as String?,
      author: json['author'] as String?,
      video_id: json['video_id'] as String?,
      keywords: json['keywords'] as String?,
      media_name: json['media_name'] as String?,
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ImagesData.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$DataDataToJson(DataData instance) => <String, dynamic>{
      'intime': instance.intime,
      'ctime': instance.ctime,
      'mtime': instance.mtime,
      'docid': instance.docid,
      'url': instance.url,
      'urls': instance.urls,
      'wapurl': instance.wapurl,
      'wapurls': instance.wapurls,
      'title': instance.title,
      'intro': instance.intro,
      'author': instance.author,
      'video_id': instance.video_id,
      'keywords': instance.keywords,
      'media_name': instance.media_name,
      'images': instance.images?.map((e) => e.toJson()).toList(),
    };

ImagesData _$ImagesDataFromJson(Map<String, dynamic> json) => ImagesData(
      u: json['u'] as String?,
      w: json['w'] as String?,
      h: json['h'] as String?,
      t: json['t'] as String?,
    );

Map<String, dynamic> _$ImagesDataToJson(ImagesData instance) =>
    <String, dynamic>{
      'u': instance.u,
      'w': instance.w,
      'h': instance.h,
      't': instance.t,
    };

StatusData _$StatusDataFromJson(Map<String, dynamic> json) => StatusData(
      code: json['code'] as int?,
      msg: json['msg'] as String?,
    );

Map<String, dynamic> _$StatusDataToJson(StatusData instance) =>
    <String, dynamic>{
      'code': instance.code,
      'msg': instance.msg,
    };
