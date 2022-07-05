// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
part 'sina_roll_news_result.g.dart';

@JsonSerializable(explicitToJson: true)
class SinaRollNewsResult {
  SinaRollNewsResultData? data;
  int? code;
  int? message;
  SinaRollNewsResult({this.data, this.code, this.message});

  factory SinaRollNewsResult.fromJson(Map<String, dynamic> json) =>
      _$SinaRollNewsResultFromJson(json);
  Map<String, dynamic> toJson() => _$SinaRollNewsResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SinaRollNewsResultData {
  ResultData? result;

  SinaRollNewsResultData({
    this.result,
  });

  factory SinaRollNewsResultData.fromJson(Map<String, dynamic> json) =>
      _$SinaRollNewsResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$SinaRollNewsResultDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ResultData {
  StatusData? status;
  String? timestamp;
  List<DataData>? data;

  ResultData({
    this.status,
    this.timestamp,
    this.data,
  });

  factory ResultData.fromJson(Map<String, dynamic> json) =>
      _$ResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$ResultDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class DataData {
  String? intime;
  String? ctime;
  String? mtime;
  String? docid;
  String? url;
  String? urls;
  String? wapurl;
  String? wapurls;
  String? title;
  String? intro;
  String? author;
  String? video_id;
  String? keywords;
  String? media_name;
  List<ImagesData>? images;

  DataData({
    this.intime,
    this.ctime,
    this.mtime,
    this.docid,
    this.url,
    this.urls,
    this.wapurl,
    this.wapurls,
    this.title,
    this.intro,
    this.author,
    this.video_id,
    this.keywords,
    this.media_name,
    this.images,
  });

  factory DataData.fromJson(Map<String, dynamic> json) =>
      _$DataDataFromJson(json);
  Map<String, dynamic> toJson() => _$DataDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ImagesData {
  String? u;
  String? w;
  String? h;
  String? t;

  ImagesData({
    this.u,
    this.w,
    this.h,
    this.t,
  });

  factory ImagesData.fromJson(Map<String, dynamic> json) =>
      _$ImagesDataFromJson(json);
  Map<String, dynamic> toJson() => _$ImagesDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StatusData {
  int? code;
  String? msg;

  StatusData({
    this.code,
    this.msg,
  });

  factory StatusData.fromJson(Map<String, dynamic> json) =>
      _$StatusDataFromJson(json);
  Map<String, dynamic> toJson() => _$StatusDataToJson(this);
}
