// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
part 'zhihu_api_daily_result.g.dart';

@JsonSerializable(explicitToJson: true)
class ZhihuApiDailyResult {
  String date;
  List<StoriesData> stories;

  ZhihuApiDailyResult({
    required this.date,
    required this.stories,
  });

  factory ZhihuApiDailyResult.fromJson(Map<String, dynamic> json) =>
      _$ZhihuApiDailyResultFromJson(json);
  Map<String, dynamic> toJson() => _$ZhihuApiDailyResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class StoriesData {
  String image_hue;
  String title;
  String url;
  String hint;
  String ga_prefix;
  List<String> images;
  int type;
  int id;

  StoriesData({
    required this.image_hue,
    required this.title,
    required this.url,
    required this.hint,
    required this.ga_prefix,
    required this.images,
    required this.type,
    required this.id,
  });

  factory StoriesData.fromJson(Map<String, dynamic> json) =>
      _$StoriesDataFromJson(json);
  Map<String, dynamic> toJson() => _$StoriesDataToJson(this);
}
