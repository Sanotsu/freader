import 'package:json_annotation/json_annotation.dart';
part 'today_in_history_result.g.dart';

@JsonSerializable(explicitToJson: true)
class TodayInHistoryResult {
  List<TodayInHistoryResultData> data;
  int code;
  String month;
  String day;
  TodayInHistoryResult({
    required this.data,
    required this.code,
    required this.month,
    required this.day,
  });

  factory TodayInHistoryResult.fromJson(Map<String, dynamic> json) =>
      _$TodayInHistoryResultFromJson(json);
  Map<String, dynamic> toJson() => _$TodayInHistoryResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TodayInHistoryResultData {
  int? year;
  String title;
  String link;
  String type;

  TodayInHistoryResultData({
    this.year,
    required this.title,
    required this.link,
    required this.type,
  });

  factory TodayInHistoryResultData.fromJson(Map<String, dynamic> json) =>
      _$TodayInHistoryResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$TodayInHistoryResultDataToJson(this);
}
