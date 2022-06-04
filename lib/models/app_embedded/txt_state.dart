/// txtstate应该包含的內容
/// 1 小说編號 、名称 、章节名称 、章节內容、章节文子数量
/// 2 显示文字大小 txtfontsize、每頁显示的文字数量 Average word count per page 、每章多少页chapterpagecount
/// 3 用户已读的哪一本小说使用哪種文字的哪一章大小的哪一页
/// id都為uuid，為字符串
///
class TxtState {
  final String txtId; // txt编号（会重复）
  final String txtName; // txt名称（会重复）
  final String chapterId; // 章节编号（不会重复）
  final String chapterName; // 章节名称（不会重复）
  final String chapterContent; // 章节正文（不会重复）
  final int chapterContentLength; // 章节正文文字数量（根据每章正文內容而定）
  const TxtState({
    required this.txtId,
    required this.txtName,
    required this.chapterId,
    required this.chapterName,
    required this.chapterContent,
    required this.chapterContentLength,
  });

  // 将一个 TxtState 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'txtId': txtId,
      'txtName': txtName,
      'chapterId': chapterId,
      'chapterName': chapterName,
      'chapterContent': chapterContent,
      'chapterContentLength': chapterContentLength
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''TxtState{txtId: $txtId, txtName: $txtName, chapterName: $chapterName,chapterId:$chapterId,
    chapterContent.length: ${chapterContent.length},chapterContentLength: $chapterContentLength}''';
  }
}

// 其实相当于TxtState的子表，根据不同的显示文字大小，存放不痛的章节页码、每页显示数量等信息，
// 预设几种字体大小提前存入，方便读取，不需要调整字体后才去重新计算
// 这如果是在不同的表，在sqlite中可能需要级联查询
class TxtChapterState {
  final String txtId; // txt编号
  final String chapterId; // 章节编号
  final int txtFontSize; // 阅读时显示的文字大小
  final int perPageAverageWordCount; // 指定文字大小后平均每页需要显示的文字数量
  final int chapterPageCount; // 该章节在平均頁面文字数量下有多少页
  const TxtChapterState({
    required this.txtId,
    required this.chapterId,
    required this.txtFontSize,
    required this.perPageAverageWordCount,
    required this.chapterPageCount,
  });

  // 将一个 TxtChapterState 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'txtId': txtId,
      'chapterId': chapterId,
      'txtFontSize': txtFontSize,
      'perPageAverageWordCount': perPageAverageWordCount,
      'chapterPageCount': chapterPageCount,
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''TxtChapterState{txtId: $txtId, chapterId:$chapterId,txtFontSize:$txtFontSize,
    perPageAverageWordCount: $perPageAverageWordCount,chapterPageCount: $chapterPageCount}''';
  }
}

// 存入多個txt的各自当前正在读的章节和章节中当前页码
class UserTxtState {
  final String userTxTStateId; // 进度主键
  final String txtId; // txt编号（会重复）
  final String currentChapterId; // 当前章节编号
  final String currentChapterPageNumber; // 当前章节当前页面
  final String currentTxtFontSize; // 当前进度对应使用的字体大小
  final String totalReadProgress; // 整体的阅读进度,默认为0,最大值100表示100%
  // 最近一次阅读的时间,如果是"-"横杆字符串，表示从未阅读过
  // 为什么不是空字符串，因为在sqlite和class之间转换，空字符串有可能变为null，会出现一些问题
  final String lastReadDatetime;
  const UserTxtState({
    required this.userTxTStateId,
    required this.txtId,
    required this.currentChapterId,
    required this.currentChapterPageNumber,
    required this.currentTxtFontSize,
    required this.totalReadProgress,
    required this.lastReadDatetime,
  });

  // 将一个 UserTxtState 转换成一个Map。键必须对应于数据库中的列名。
  Map<String, dynamic> toMap() {
    return {
      'userTxTStateId': userTxTStateId,
      'txtId': txtId,
      'currentChapterId': currentChapterId,
      'currentChapterPageNumber': currentChapterPageNumber,
      'currentTxtFontSize': currentTxtFontSize,
      'totalReadProgress': totalReadProgress,
      'lastReadDatetime': lastReadDatetime
    };
  }

  // 重写 toString 方法
  @override
  String toString() {
    return '''UserTxtState{
      userTxTStateId:$userTxTStateId,txtId: $txtId, currentChapterId: $currentChapterId,
     currentChapterPageNumber: $currentChapterPageNumber,
     currentTxtFontSize:$currentTxtFontSize,totalReadProgress: $totalReadProgress, 
     lastReadDatetime: $lastReadDatetime}''';
  }
}
