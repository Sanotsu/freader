// ignore_for_file: non_constant_identifier_names

/// 因为原json就是 下划线属性,如果这里的属性用了驼峰,不一定能匹配到值

import 'package:json_annotation/json_annotation.dart';
part 'hitokoto_result.g.dart';

@JsonSerializable(explicitToJson: true)
class HitokotoResult {
  HitokotoResultData? data;
  int? code;
  int? message;
  HitokotoResult({this.data, this.code, this.message});

  factory HitokotoResult.fromJson(Map<String, dynamic> json) =>
      _$HitokotoResultFromJson(json);
  Map<String, dynamic> toJson() => _$HitokotoResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class HitokotoResultData {
  int? id;
  String? uuid;
  String? hitokoto;
  String? type;
  String? from;
  String? from_who;
  String? creator;
  int? creator_uid;
  int? reviewer;
  String? commit_from;
  String? created_at;
  int? length;

  HitokotoResultData({
    this.id,
    this.uuid,
    this.hitokoto,
    this.type,
    this.from,
    this.from_who,
    this.creator,
    this.creator_uid,
    this.reviewer,
    this.commit_from,
    this.created_at,
    this.length,
  });

  factory HitokotoResultData.fromJson(Map<String, dynamic> json) =>
      _$HitokotoResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$HitokotoResultDataToJson(this);
}
