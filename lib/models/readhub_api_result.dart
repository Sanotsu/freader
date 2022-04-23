import 'package:json_annotation/json_annotation.dart';

part 'readhub_api_result.g.dart';

@JsonSerializable(explicitToJson: true)
class ReadhubApiResult {
  ReadhubApiResultData? data;
  int? code;
  int? message;
  ReadhubApiResult({this.data, this.code, this.message});

  factory ReadhubApiResult.fromJson(Map<String, dynamic> json) =>
      _$ReadhubApiResultFromJson(json);
  Map<String, dynamic> toJson() => _$ReadhubApiResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ReadhubApiResultData {
  int? totalItems;
  int? startIndex;
  int? pageIndex;
  int? itemsPerPage;
  int? currentItemCount;
  int? totalPages;
  List<ItemsData>? items;

  ReadhubApiResultData({
    this.totalItems,
    this.startIndex,
    this.pageIndex,
    this.itemsPerPage,
    this.currentItemCount,
    this.totalPages,
    this.items,
  });

  factory ReadhubApiResultData.fromJson(Map<String, dynamic> json) =>
      _$ReadhubApiResultDataFromJson(json);
  Map<String, dynamic> toJson() => _$ReadhubApiResultDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ItemsData {
  String? uid;
  String? title;
  String? summary;
  String? createdAt;
  int? siteCount;
  String? siteNameDisplay;
  List<NewsagglistData>? newsAggList;
  bool? up;
  bool? hasView;
  String? timelineId;
  List<dynamic>? entityList;
  List<dynamic>? eventList;
  List<TaglistData>? tagList;

  ItemsData({
    this.uid,
    this.title,
    this.summary,
    this.createdAt,
    this.siteCount,
    this.siteNameDisplay,
    this.newsAggList,
    this.up,
    this.hasView,
    this.timelineId,
    this.entityList,
    this.eventList,
    this.tagList,
  });

  factory ItemsData.fromJson(Map<String, dynamic> json) =>
      _$ItemsDataFromJson(json);
  Map<String, dynamic> toJson() => _$ItemsDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class TaglistData {
  String? uid;
  String? name;

  TaglistData({
    this.uid,
    this.name,
  });

  factory TaglistData.fromJson(Map<String, dynamic> json) =>
      _$TaglistDataFromJson(json);
  Map<String, dynamic> toJson() => _$TaglistDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class NewsagglistData {
  String? url;
  String? title;
  String? siteNameDisplay;

  NewsagglistData({
    this.url,
    this.title,
    this.siteNameDisplay,
  });

  factory NewsagglistData.fromJson(Map<String, dynamic> json) =>
      _$NewsagglistDataFromJson(json);
  Map<String, dynamic> toJson() => _$NewsagglistDataToJson(this);
}
