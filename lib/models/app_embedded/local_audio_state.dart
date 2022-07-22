import 'dart:convert';

/// 2022-07-21
/// 更新，还是改为完善的3张表
///     音频基础信息表 LocalAudioInfo、
///     歌单基础信息表 LocalAudioPlaylistInfo、
///     歌单音频关联表 LocalPlaylistHasAudio
/// 由于在渲染歌单时再查询歌单元数据，会导致渲染很慢，所以在存入音频信息表的时候，就存入构建列表时常用的元数据，
/// 其他部分再指定查询单个音频时再从音频文件中去获取元数据

/// 音频信息基础表对应类
///     参考just-audio的 MediaItem 类 MediaItem({
//          required String id,     // 歌曲编号
//          required String title,  // 歌曲名
//          String? album,          // 专辑
//          String? artist,         // 歌手
//          String? genre,          // 流派
//          Duration? duration,     // 时长
//          Uri? artUri,            // 专辑图片地址（本地、网络）
//          Map<String, String>? artHeaders,  // 专辑图片uri所用的header
//          bool? playable = true,    // 是否可播放的
//          String? displayTitle,     // 用于显示的标题
//          String? displaySubtitle,  // 用于显示的小标题
//          String? displayDescription, // 用于显示的表述
//          Rating? rating,             // 音频的评分
//          Map<String, dynamic>? extras,   // 额外元数据信息（例如我用来放音频元数据的专辑图片二进制数据）
//        })
class LocalAudioInfo {
  // 音频代号（不重复，例如网易云等有自己编号，后续可以用其来查询。没有的就uuid）
  final String audioId;
  final String audioName; // 音频名称
  final String audioPath; // 本地路径
  final String? artist; // 歌手
  final String? album; // 专辑
  final String? displayTitle; // 用于显示的歌名(如果音频文件名是乱码，解析出来的歌名可以顶上)
  final Map<String, dynamic>? extras; // 额外数据

  const LocalAudioInfo({
    required this.audioId,
    required this.audioName,
    required this.audioPath,
    this.artist,
    this.album,
    this.displayTitle,
    this.extras,
  });

  // 将一个 LocalAudioInfo 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'audioId': audioId,
      'audioName': audioName,
      'audioPath': audioPath,
      'artist': artist,
      'album': album,
      'displayTitle': displayTitle,
      'extras': jsonEncode(extras),
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''LocalAudioInfo{audioId: $audioId, audioName: $audioName, audioPath: $audioPath,
    artist: $artist,album: $album,displayTitle: $displayTitle,extras: $extras}''';
  }
}

/// 播放列表基础表对应类
// 还是单纯点就好
// late 是为了转fromJson时需要
class LocalAudioPlaylist {
  // 歌单编号（如果某些平台有的，可以用来查询。否则就是本地uuid）
  late String playlistId;
  // 歌单名称
  late String playlistName;
  // 歌单描述
  late String? playlistDescription;
  // 歌单标签
  late String? playlistTag;
  // 歌单额外信息（封面之类的）
  late Map<String, dynamic>? extras; // 额外数据

  LocalAudioPlaylist({
    required this.playlistId,
    required this.playlistName,
    this.playlistDescription,
    this.playlistTag,
    this.extras,
  });

  // 将一个 LocalAudioPlaylist 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'playlistId': playlistId,
      'playlistName': playlistName,
      'playlistDescription': playlistDescription,
      'playlistTag': playlistTag,
      'extras': jsonEncode(extras),
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''LocalAudioPlaylist{playlistId: $playlistId, audioPlaylistName:$playlistName,
    playlistDescription:$playlistDescription,playlistTag:$playlistTag,extras:$extras}''';
  }
}

/// 歌单和歌曲的关联表
/// 为了实用，用空间换时间
class LocalPlaylistHasAudio {
  // 关联关系主键
  late String localPlaylistHasAudioId;
  // 歌单编号
  late String playlistId;
  // 音频编号
  late String audioId;
  // 歌单名称
  late String? playlistName;
  // 音频名称
  late String? audioName;
  // 音频路径
  late String? audioPath;
  // 歌单额外信息（封面之类的）
  late Map<String, dynamic>? extras; // 额外数据

  LocalPlaylistHasAudio({
    required this.localPlaylistHasAudioId,
    required this.playlistId,
    required this.audioId,
    this.playlistName,
    this.audioName,
    this.audioPath,
    this.extras,
  });

  // 将一个 LocalPlaylistHasAudio 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'localPlaylistHasAudioId': localPlaylistHasAudioId,
      'playlistId': playlistId,
      'audioId': audioId,
      'playlistName': playlistName,
      'audioName': audioName,
      'audioPath': audioPath,
      'extras': jsonEncode(extras),
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''LocalAudioPlaylist{localPlaylistHasAudioId: $localPlaylistHasAudioId, playlistId:$playlistId,
    audioId:$audioId,playlistName:$playlistName,audioName:$audioName,audioPath:$audioPath,extras:$extras}''';
  }

  /// 在音频列表的音频元数据的额外属性上用字符串
  // 为了能转换为string，还能再转回类型来。
  LocalPlaylistHasAudio.fromJson(Map<String, dynamic> json) {
    localPlaylistHasAudioId = json['localPlaylistHasAudioId'];
    playlistId = json['playlistId'];
    audioId = json['audioId'];
    playlistName = json['playlistName'];
    audioName = json['audioName'] ?? "";
    audioPath = json['audioPath'] ?? "";
    extras = json['extras'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final _data = <String, dynamic>{};
    _data['localPlaylistHasAudioId'] = localPlaylistHasAudioId;
    _data['playlistId'] = playlistId;
    _data['audioId'] = audioId;
    _data['playlistName'] = playlistName;
    _data['audioName'] = audioName;
    _data['audioPath'] = audioPath;
    _data['extras'] = extras;
    return _data;
  }
}
