import 'package:json_annotation/json_annotation.dart';
part 'readhub_api_common_result.g.dart';

@JsonSerializable(explicitToJson: true)
class ReadhubApiCommonResult {
  ReadhubApiCommonResultData data;
  int code;
  int message;
  ReadhubApiCommonResult(
      {required this.data, required this.code, required this.message});

  factory ReadhubApiCommonResult.fromJson(Map<String, dynamic> json) =>
      _$ReadhubApiCommonResultFromJson(json);
  Map<String, dynamic> toJson() => _$ReadhubApiCommonResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReadhubApiCommonResultData {
  int totalItems;
  int startIndex;
  int pageIndex;
  int itemsPerPage;
  int currentItemCount;
  int totalPages;
  List<ItemsData> items;

  ReadhubApiCommonResultData({
    required this.totalItems,
    required this.startIndex,
    required this.pageIndex,
    required this.itemsPerPage,
    required this.currentItemCount,
    required this.totalPages,
    required this.items,
  });

  factory ReadhubApiCommonResultData.fromJson(Map<String, dynamic> json) =>
      _$ReadhubApiCommonResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$ReadhubApiCommonResultDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ItemsData {
  String uid;
  String title;
  String summary;
  String url;
  String siteNameDisplay;
  String createdAt;

  ItemsData({
    required this.uid,
    required this.title,
    required this.summary,
    required this.url,
    required this.siteNameDisplay,
    required this.createdAt,
  });

  factory ItemsData.fromJson(Map<String, dynamic> json) =>
      _$ItemsDataFromJson(json);
  Map<String, dynamic> toJson() => _$ItemsDataToJson(this);
}
