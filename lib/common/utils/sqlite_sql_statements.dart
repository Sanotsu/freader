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

  /// 记录pdf状态
  ///  id             编号
  ///  filename       文件名
  ///  filepath       文件路径
  ///  source         来源（目前3种：內嵌 embedded 、扫描本机所有有权限的文件夹 scanned 、自行打开文件夹选择 picked）
  ///  readProgress   阅读进度,默认为0
  static const String createTable4PdfState = """
    CREATE TABLE pdf_state (
    id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT UNIQUE, 
    filename TEXT, 
    filepath TEXT,
    source TEXT, 
    readProgress TEXT);
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
}
