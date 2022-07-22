/// pdf_state 文件来源 source （目前3种：內嵌 embedded 、扫描本机所有有权限的文件夹 scanned 、自行打开文件夹选择 picked）
enum PdfStateSource { embedded, scanned, picked }

/// sqlite中创建table的sql语句
class SqliteSqlStatements {
  /// db name、table names
  ///   // db名称
  static String databaseName = "freader_embedded.db";
  // 表名
  static String tableNameOfPdfState = 'pdf_state';
  static String tableNameOfHitokoto = 'hitokoto';
  // txt viewer相关
  static String tableNameOfTxtState = 'txt_state';
  static String tableNameOfTxtChapterState = 'txt_chapter_state';
  static String tableNameOfUserTxtState = 'user_txt_state';

  /// // 音频播放模块专门生成专门内嵌db文件
  static String audioDbName = "freader_audio_embedded.db";
  //  音频模块表名
  static String tableNameOfLocalAudioInfo = 'local_audio_info';
  static String tableNameOfLocalAudioPlaylist = 'local_audio_playlist';
  static String tableNameOfLocalPlaylistHasAudio = 'local_playlist_has_audio';

  /// 记录pdf状态
  ///  id             编号
  ///  filename       文件名
  ///  filepath       文件路径
  ///  source         来源（目前3种：內嵌 embedded 、扫描本机所有有权限的文件夹 scanned 、自行打开文件夹选择 picked）
  ///  readProgress   阅读进度,默认为0
  ///  lastReadDatetime   上次阅读的时间
  static const String createTable4PdfState = """
    CREATE TABLE pdf_state (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    filename TEXT, 
    filepath TEXT,
    source TEXT, 
    readProgress TEXT,
    lastReadDatetime TEXT);
    """;

  /// 记录一言获取记录
  /// id          编号
  /// createdTime 该语句获取时间
  /// hitokoto    语句正文
  /// author      作者
  /// literature  来源作品名称
  static const String createTable4Hitokoto = """
    CREATE TABLE hitokoto (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    createdTime TEXT, 
    hitokoto TEXT NOT NULL, 
    author TEXT,
    literature TEXT);
    """;

  /// txt正文內容
  static const String createTable4TxtState = """
    CREATE TABLE txt_state (
    txtId TEXT NOT NULL, 
    txtName TEXT NOT NULL, 
    chapterId TEXT NOT NULL, 
    chapterName TEXT NOT NULL,
    chapterContent TEXT NOT NULL,
    chapterContentLength INTEGER NOT NULL
    );
    """;

  /// txt章节元数据
  static const String createTable4TxtChapterState = """
    CREATE TABLE txt_chapter_state (
    txtId TEXT NOT NULL, 
    chapterId TEXT NOT NULL, 
    txtFontSize INTEGER NOT NULL, 
    perPageAverageWordCount INTEGER NOT NULL,
    chapterPageCount INTEGER NOT NULL
    );
    """;

  /// txt用户阅读进度
  static const String createTable4UserTxtState = """
    CREATE TABLE user_txt_state (
    userTxTStateId TEXT NOT NULL,
    txtId TEXT NOT NULL, 
    currentChapterId TEXT NOT NULL, 
    currentChapterPageNumber TEXT NOT NULL, 
    currentTxtFontSize TEXT NOT NULL, 
    totalReadProgress TEXT NOT NULL,
    lastReadDatetime TEXT NOT NULL
    );
    """;

  // ========================== 参看local_audio_state文件定义
  // (2022-07-16:为什么之前数据库栏位名用的驼峰而不是底斜线？
  //        因为这样在类转db栏位，或者查询时栏位转类没有区别，不怕搞混)
  /// 音频文件信息（极简，只存名称和本地路径）
  // 如果是网络音乐，可能需要缓存到本地之后，存入缓存路径，进行播放和其他信息获取

  // Map类型存进来用string，查出来在json为map看行不行
  static const String createTable4LocalAudioInfo = """
    CREATE TABLE local_audio_info (
    audioId TEXT NOT NULL,
    audioName TEXT NOT NULL, 
    audioPath TEXT NOT NULL,
    artist TEXT,
    album TEXT,
    displayTitle TEXT,
    extras TEXT 
    );
    """;

  /// 歌单列表
  ///  要是不想多表查询，多两个音频属性属性
  static const String createTable4LocalAudioPlaylist = """
    CREATE TABLE local_audio_playlist (
    playlistId TEXT NOT NULL,
    playlistName TEXT NOT NULL,
    playlistDescription TEXT,
    playlistTag TEXT,
    extras TEXT
    );
    """;

  /// 歌单列表（极简，只存名称和对应音频基础信息）
  ///  要是不想多表查询，多两个音频属性属性
  static const String createTable4LocalPlaylistHasAudio = """
    CREATE TABLE local_playlist_has_audio (
    localPlaylistHasAudioId TEXT NOT NULL,
    playlistId TEXT NOT NULL,
    audioId TEXT  NOT NULL,
    playlistName TEXT,
    audioName TEXT,
    audioPath TEXT,
    extras TEXT
    );
    """;
}
