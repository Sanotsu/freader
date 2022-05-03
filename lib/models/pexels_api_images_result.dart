// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
part 'pexels_api_images_result.g.dart';

/// 保留原本api返回json的栏位，不作驼峰命名。

@JsonSerializable(explicitToJson: true)
class PexelsApiImagesResult {
  int? page;
  int? per_page;
  List<PhotosData>? photos;
  int? total_results;
  String? next_page;

  PexelsApiImagesResult({
    this.page,
    this.per_page,
    this.photos,
    this.total_results,
    this.next_page,
  });

  factory PexelsApiImagesResult.fromJson(Map<String, dynamic> json) =>
      _$PexelsApiImagesResultFromJson(json);
  Map<String, dynamic> toJson() => _$PexelsApiImagesResultToJson(this);
}

@JsonSerializable(explicitToJson: true)
class PhotosData {
  int? id;
  int? width;
  int? height;
  String? url;
  String? photographer;
  String? photographer_url;
  int? photographer_id;
  String? avg_color;
  SrcData? src;
  bool? liked;
  String? alt;

  PhotosData({
    this.id,
    this.width,
    this.height,
    this.url,
    this.photographer,
    this.photographer_url,
    this.photographer_id,
    this.avg_color,
    this.src,
    this.liked,
    this.alt,
  });

  factory PhotosData.fromJson(Map<String, dynamic> json) =>
      _$PhotosDataFromJson(json);
  Map<String, dynamic> toJson() => _$PhotosDataToJson(this);
}

@JsonSerializable(explicitToJson: true)
class SrcData {
  String? original;
  String? large2x;
  String? large;
  String? medium;
  String? small;
  String? portrait;
  String? landscape;
  String? tiny;

  SrcData({
    this.original,
    this.large2x,
    this.large,
    this.medium,
    this.small,
    this.portrait,
    this.landscape,
    this.tiny,
  });

  factory SrcData.fromJson(Map<String, dynamic> json) =>
      _$SrcDataFromJson(json);
  Map<String, dynamic> toJson() => _$SrcDataToJson(this);
}
