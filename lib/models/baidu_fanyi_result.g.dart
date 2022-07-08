// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baidu_fanyi_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BaiduFanyiResult _$BaiduFanyiResultFromJson(Map<String, dynamic> json) =>
    BaiduFanyiResult(
      from: json['from'] as String,
      to: json['to'] as String,
      trans_result: (json['trans_result'] as List<dynamic>)
          .map((e) => TransResultData.fromJson(e as Map<String, dynamic>))
          .toList(),
      error_code: json['error_code'] as String?,
      error_msg: json['error_msg'] as String?,
    );

Map<String, dynamic> _$BaiduFanyiResultToJson(BaiduFanyiResult instance) =>
    <String, dynamic>{
      'from': instance.from,
      'to': instance.to,
      'trans_result': instance.trans_result.map((e) => e.toJson()).toList(),
      'error_code': instance.error_code,
      'error_msg': instance.error_msg,
    };

TransResultData _$TransResultDataFromJson(Map<String, dynamic> json) =>
    TransResultData(
      src: json['src'] as String,
      dst: json['dst'] as String,
    );

Map<String, dynamic> _$TransResultDataToJson(TransResultData instance) =>
    <String, dynamic>{
      'src': instance.src,
      'dst': instance.dst,
    };
