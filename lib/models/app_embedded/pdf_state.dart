class PdfState {
  final int? id; // id
  final String filename; // 文件名
  final String filepath; // 文件路径
  // 文件来源 （目前3种：內嵌 embedded 、扫描本机所有有权限的文件夹 scanned 、自行打开文件夹选择 picked）
  final String source;
  final double readProgress; // 阅读进度,默认为0,最大值100表示100%
  // 最近一次阅读的时间,如果是"-"横杆字符串，表示从未阅读过
  // 为什么不是空字符串，因为在sqlite和class之间转换，空字符串有可能变为null，会出现一些问题
  final String lastReadDatetime;
  const PdfState({
    this.id,
    required this.filename,
    required this.filepath,
    required this.source,
    required this.readProgress,
    required this.lastReadDatetime,
  });

  // 将一个PdfState转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'filename': filename,
      'filepath': filepath,
      'source': source,
      'readProgress': readProgress,
      'lastReadDatetime': lastReadDatetime
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''PdfState{id: $id, filename: $filename, filepath: $filepath,source: $source,
     readProgress: $readProgress, lastReadDatetime: $lastReadDatetime}''';
  }
}
