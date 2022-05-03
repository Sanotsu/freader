// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pexels_api_images_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PexelsApiImagesResult _$PexelsApiImagesResultFromJson(
        Map<String, dynamic> json) =>
    PexelsApiImagesResult(
      page: json['page'] as int?,
      per_page: json['per_page'] as int?,
      photos: (json['photos'] as List<dynamic>?)
          ?.map((e) => PhotosData.fromJson(e as Map<String, dynamic>))
          .toList(),
      total_results: json['total_results'] as int?,
      next_page: json['next_page'] as String?,
    );

Map<String, dynamic> _$PexelsApiImagesResultToJson(
        PexelsApiImagesResult instance) =>
    <String, dynamic>{
      'page': instance.page,
      'per_page': instance.per_page,
      'photos': instance.photos?.map((e) => e.toJson()).toList(),
      'total_results': instance.total_results,
      'next_page': instance.next_page,
    };

PhotosData _$PhotosDataFromJson(Map<String, dynamic> json) => PhotosData(
      id: json['id'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      url: json['url'] as String?,
      photographer: json['photographer'] as String?,
      photographer_url: json['photographer_url'] as String?,
      photographer_id: json['photographer_id'] as int?,
      avg_color: json['avg_color'] as String?,
      src: json['src'] == null
          ? null
          : SrcData.fromJson(json['src'] as Map<String, dynamic>),
      liked: json['liked'] as bool?,
      alt: json['alt'] as String?,
    );

Map<String, dynamic> _$PhotosDataToJson(PhotosData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'width': instance.width,
      'height': instance.height,
      'url': instance.url,
      'photographer': instance.photographer,
      'photographer_url': instance.photographer_url,
      'photographer_id': instance.photographer_id,
      'avg_color': instance.avg_color,
      'src': instance.src?.toJson(),
      'liked': instance.liked,
      'alt': instance.alt,
    };

SrcData _$SrcDataFromJson(Map<String, dynamic> json) => SrcData(
      original: json['original'] as String?,
      large2x: json['large2x'] as String?,
      large: json['large'] as String?,
      medium: json['medium'] as String?,
      small: json['small'] as String?,
      portrait: json['portrait'] as String?,
      landscape: json['landscape'] as String?,
      tiny: json['tiny'] as String?,
    );

Map<String, dynamic> _$SrcDataToJson(SrcData instance) => <String, dynamic>{
      'original': instance.original,
      'large2x': instance.large2x,
      'large': instance.large,
      'medium': instance.medium,
      'small': instance.small,
      'portrait': instance.portrait,
      'landscape': instance.landscape,
      'tiny': instance.tiny,
    };
