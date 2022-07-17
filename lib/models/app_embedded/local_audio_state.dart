/// 音频信息基础表对应类
class LocalAudioInfo {
  // 音频代号（不重复，例如网易云等有自己编号，后续可以用其来查询。没有的就uuid）
  final String audioId;
  final String audioName; // 音频名称
  final String audioPath; // 本地路径

  const LocalAudioInfo({
    required this.audioId,
    required this.audioName,
    required this.audioPath,
  });

  // 将一个 TxtState 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'audioId': audioId,
      'audioName': audioName,
      'audioPath': audioPath,
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''LocalAudioInfo{audioId: $audioId, audioName: $audioName, audioPath: $audioPath}''';
  }
}

/// 播放列表基础表对应类
// 说明，为了方便，本来应该是 歌单信息表+歌单歌曲关系表 两张表，就放到一起去了。歌单id+audioId联合主键
// 正常来讲还有很多功能，比如当前听到指定歌单的哪一首歌什么的，各种用户状态什么的，先不弄了。
class LocalAudioPlaylist {
  // 歌单编号（如果某些平台有的，可以用来查询。否则就是本地uuid）
  final String audioPlaylistId;
  // 歌单名称
  final String audioPlaylistName;
  // 音频编号 （如果是平台的歌单，那肯定里面的歌也有对应的id。否则就是本地的uuid）
  final String audioId;
  // 为了方便直接重复的基本数据，`避免 联合查询或者使用rawQuery(),还要新建复合后的类型`
  final String audioName; // 音频名称
  final String audioPath; // 本地路径

  const LocalAudioPlaylist({
    required this.audioPlaylistId,
    required this.audioPlaylistName,
    required this.audioId,
    required this.audioName,
    required this.audioPath,
  });

  // 将一个 TxtChapterState 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'audioPlaylistId': audioPlaylistId,
      'audioPlaylistName': audioPlaylistName,
      'audioId': audioId,
      'audioName': audioName,
      'audioPath': audioPath,
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''LocalAudioPlaylist{audioPlaylistId: $audioPlaylistId, audioPlaylistName:$audioPlaylistName,
    audioId:$audioId,audioName:$audioName,audioPath:$audioPath}''';
  }
}
