// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
part 'baidu_fanyi_result.g.dart';

@JsonSerializable(explicitToJson: true)
class BaiduFanyiResult {
  String from;
  String to;
  List<TransResultData> trans_result;
  String? error_code;
  String? error_msg;

  BaiduFanyiResult({
    required this.from,
    required this.to,
    required this.trans_result,
    this.error_code,
    this.error_msg,
  });

  factory BaiduFanyiResult.fromJson(Map<String, dynamic> json) =>
      _$BaiduFanyiResultFromJson(json);
  Map<String, dynamic> toJson() => _$BaiduFanyiResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TransResultData {
  String src;
  String dst;

  TransResultData({
    required this.src,
    required this.dst,
  });

  factory TransResultData.fromJson(Map<String, dynamic> json) =>
      _$TransResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$TransResultDataToJson(this);
}
