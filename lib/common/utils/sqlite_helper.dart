// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:freader/common/utils/sqlite_sql_statements.dart';
import 'package:freader/models/app_embedded/pdf_state.dart';
import 'package:freader/models/app_embedded/txt_state.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _databaseHelper =
      DatabaseHelper._createInstance();
  static Database? _database;

// 命名的构造函数用于创建DatabaseHelper的实例
  DatabaseHelper._createInstance();

  factory DatabaseHelper() {
    return _databaseHelper;
  }

  Future<Database> get database async =>
      _database ??= await initializeDatabase();

  /// 初始化数据库
  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "/" + SqliteSqlStatements.databaseName;

    print("00000000000000000000000$path");

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  // 创建表
  void _createDb(Database db, int newVersion) async {
    // pdf viewer相关
    await db.execute(SqliteSqlStatements.createTable4PdfState);
    // 一言相关
    await db.execute(SqliteSqlStatements.createTable4Hitokoto);
    // txt viewer相關
    await db.execute(SqliteSqlStatements.createTable4TxtState);
    await db.execute(SqliteSqlStatements.createTable4TxtChapterState);
    await db.execute(SqliteSqlStatements.createTable4UserTxtState);
  }

  // 关闭数据库
  void closeDatabase() async {
    Database db = await database;

    print(db.isOpen);
    await db.close();
    print(db.isOpen);
  }

  // 删除sqlite的db文件（初始化数据库操作中那个path的值）
  void deleteDb() async {
    print("开始删除內嵌的sqlite db文件");
    await deleteDatabase(
        "/data/user/0/com.example.freader/app_flutter/freader_embedded.db");
  }

// 显示db中已有的table，默认的和自建立的
  void showTableNameList() async {
    Database db = await database;
    var tableNames = (await db
            .query('sqlite_master', where: 'type = ?', whereArgs: ['table']))
        .map((row) => row['name'] as String)
        .toList(growable: false);

    // for (var row
    //     in (await db.query('sqlite_master', columns: ['type', 'name']))) {
    //   print(row.values);
    // }

    print("------------1111");
    print(tableNames);
    print("------------1111");
  }

  ///================pdfState 数据库表值对应的操作（为了简单，都是Row级别）
  // pdfState 插入数据
  Future<int> insertPdfState(PdfState pdfState) async {
    Database db = await database;
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfPdfState,
      pdfState.toMap(),
    );
    return result;
  }

  // pdfState 修改数据
  Future<int> updatePdfState(PdfState pdfState) async {
    Database db = await database;
    var result = await db.update(
      SqliteSqlStatements.tableNameOfPdfState,
      pdfState.toMap(),
      // 确保Id存在.
      where: 'id = ?',
      // 传递 pdfState 的id作为whereArg，以防止SQL注入。
      whereArgs: [pdfState.id],
    );
    return result;
  }

  // pdfState 删除数据
  Future<int> deletePdfState(int id) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfPdfState,
      where: "id=?",
      whereArgs: [id],
    );
    return result;
  }

  // pdfState 指定栏位查询
  /// 2022-05-11 如果是同一文件名但路径不在一起，那也是两条数据。在新增逻辑中注意区别
  Future<List<PdfState>> queryPdfStateByFilename(String filename) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfPdfState,
      where: "filename=?",
      whereArgs: [filename],
    );

    return List.generate(maps.length, (i) {
      return PdfState(
        id: maps[i]['id'],
        filename: maps[i]['filename'],
        filepath: maps[i]['filepath'],
        source: maps[i]['source'],
        readProgress: double.parse(maps[i]['readProgress']),
        lastReadDatetime: maps[i]['lastReadDatetime'],
      );
    });
  }

  // 获取pdfstate表中的所有数据
  Future<List<PdfState>> readPdfStateList() async {
    // Get a reference to the database.
    final db = await database;

    // Query the table for all The PdfState.
    final List<Map<String, dynamic>> maps =
        await db.query(SqliteSqlStatements.tableNameOfPdfState);

    //将 List<Map<String, dynamic> 转换成 List<PdfState> 数据类型
    return List.generate(maps.length, (i) {
      return PdfState(
        id: maps[i]['id'],
        filename: maps[i]['filename'],
        filepath: maps[i]['filepath'],
        source: maps[i]['source'],
        readProgress: double.parse(maps[i]['readProgress']),
        lastReadDatetime: maps[i]['lastReadDatetime'],
      );
    });
  }

  ///================ TxtState 数据库表值对应的操作（为了简单，都是Row级别）
  // 插入数据
  Future<int> insertTxtState(TxtState txtState) async {
    Database db = await database;
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfTxtState,
      txtState.toMap(),
    );
    return result;
  }

  // 修改数据
  Future<int> updateTxtState(TxtState txtState) async {
    Database db = await database;
    var result = await db.update(
      SqliteSqlStatements.tableNameOfTxtState,
      txtState.toMap(),
      // 确保Id存在.
      where: 'txtId = ? and chapterId =? ', // 不一定是这样写的。。。。。。。
      // 传递 的id作为whereArg，以防止SQL注入。
      whereArgs: [txtState.txtId, txtState.chapterId],
    );
    return result;
  }

  //  删除数据(指定txt指定章节)
  Future<int> deleteTxtState(String txtId, String chapterId) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfTxtState,
      where: 'txtId = ? and chapterId = ? ',
      whereArgs: [txtId, chapterId],
    );
    return result;
  }

  //  删除所有数据
  Future<int> deleteAllTxtState() async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfTxtState,
    );
    return result;
  }

  //  查询指定txt指定章节的正文，传入兩個id
  Future<List<TxtState>> queryTxtStateByIds(
      String txtId, String chapterId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfTxtState,
      where: 'txtId = ? and chapterId = ? ',
      whereArgs: [txtId, chapterId],
    );

    return List.generate(maps.length, (i) {
      return TxtState(
        txtId: maps[i]['txtId'],
        txtName: maps[i]['txtName'],
        chapterId: maps[i]['chapterId'],
        chapterName: maps[i]['chapterName'],
        chapterContent: maps[i]['chapterContent'],
        chapterContentLength: maps[i]['chapterContentLength'],
      );
    });
  }

// 需要按txt编号获取指定数量章节的内容
  Future<List<TxtState>> queryFirstTxtStateByTxtId(String txtId,
      {int? number}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfTxtState,
      where: 'txtId = ?',
      whereArgs: [txtId],
      // chapterId虽然是1,2,3这样的字符串数字，但排序时是字符串规则，则按照升序的话10 会在2 前面
      // 因此chapterId+0 ，强行转换为int再排序，就不会出现上述问题了
      orderBy: "chapterId+0 ASC",
      limit: number ?? 10000, // 不会有1w条，相当于查询所有
    );

    return List.generate(maps.length, (i) {
      return TxtState(
        txtId: maps[i]['txtId'],
        txtName: maps[i]['txtName'],
        chapterId: maps[i]['chapterId'],
        chapterName: maps[i]['chapterName'],
        chapterContent: maps[i]['chapterContent'],
        chapterContentLength: maps[i]['chapterContentLength'],
      );
    });
  }

  // 获取 TxtState 表中的所有数据
  Future<List<TxtState>> readTxtStateList() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfTxtState,
      // 栏位不查询chapterContent，加载到内存太大了
      columns: [
        'txtId',
        "txtName",
        "chapterId",
        "chapterName",
        "chapterContentLength"
      ],
    );

    //将 List<Map<String, dynamic> 转换成 List<PdfState> 数据类型
    return List.generate(maps.length, (i) {
      return TxtState(
        txtId: maps[i]['txtId'],
        txtName: maps[i]['txtName'],
        chapterId: maps[i]['chapterId'],
        chapterName: maps[i]['chapterName'],
        // 查看所有数据，文本全部拿出来太大了，这里就返回长度好了
        chapterContent: "${maps[i]['chapterContentLength']}",
        // chapterContent: maps[i]['chapterContent'],
        chapterContentLength: maps[i]['chapterContentLength'],
      );
    });
  }

  ///================ TxtChapterState 数据库表值对应的操作（为了简单，都是Row级别）
  // 插入数据
  Future<int> insertTxtChapterState(TxtChapterState txtChapterState) async {
    Database db = await database;
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfTxtChapterState,
      txtChapterState.toMap(),
    );
    return result;
  }

  //  删除数据(指定txt指定章节)
  Future<int> deleteTxtChapterState(String txtId, String chapterId) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfTxtChapterState,
      where: 'txtId = ? and chapterId = ? ',
      whereArgs: [txtId, chapterId],
    );
    return result;
  }

  //  查询指定txt指定章节的元数据，传入兩個id
  Future<List<TxtChapterState>> queryTxtChapterStateByIds(
      String txtId, String chapterId) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfTxtChapterState,
      where: 'txtId = ? and chapterId =? ',
      whereArgs: [txtId, chapterId],
    );

    return List.generate(maps.length, (i) {
      return TxtChapterState(
        txtId: maps[i]['txtId'],
        chapterId: maps[i]['chapterId'],
        txtFontSize: maps[i]['txtFontSize'],
        perPageAverageWordCount: maps[i]['perPageAverageWordCount'],
        chapterPageCount: maps[i]['chapterPageCount'],
      );
    });
  }

  // 获取 TxtChapterState 表中的所有数据
  Future<List<TxtChapterState>> readTxtChapterStateList() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query(SqliteSqlStatements.tableNameOfTxtChapterState);

    //将 List<Map<String, dynamic> 转换成 List<> 数据类型
    return List.generate(maps.length, (i) {
      return TxtChapterState(
        txtId: maps[i]['txtId'],
        chapterId: maps[i]['chapterId'],
        txtFontSize: maps[i]['txtFontSize'],
        perPageAverageWordCount: maps[i]['perPageAverageWordCount'],
        chapterPageCount: maps[i]['chapterPageCount'],
      );
    });
  }

  ///================ UserTxtState 数据库表值对应的操作（为了简单，都是Row级别）
  // 插入数据
  Future<int> insertUserTxtState(UserTxtState userTxtState) async {
    Database db = await database;
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfUserTxtState,
      userTxtState.toMap(),
    );
    return result;
  }

  // 修改数据
  Future<int> updateUserTxtState(UserTxtState userTxtState) async {
    Database db = await database;
    var result = await db.update(
      SqliteSqlStatements.tableNameOfUserTxtState,
      userTxtState.toMap(),
      // 确保Id存在.
      where: 'txtId = ?',
      // 传递 的id作为whereArg，以防止SQL注入。
      whereArgs: [userTxtState.txtId],
    );
    return result;
  }

  //  查询指定txt的阅读进度，传入兩個id
  // 如果没传章节编号，可能是确定该txt有没有被阅读过
  Future<List<UserTxtState>> queryUserTxtStateByTxtId(String txtId,
      {String? chapterId}) async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfUserTxtState,
      where: chapterId != null ? 'txtId = ? and chapterId =? ' : 'txtId = ?',
      whereArgs: chapterId != null ? [txtId, chapterId] : [txtId],
    );

    print("=======================");
    print(maps);

    return List.generate(maps.length, (i) {
      return UserTxtState(
        userTxTStateId: maps[i]['userTxTStateId'],
        txtId: maps[i]['txtId'],
        currentChapterId: maps[i]['currentChapterId'],
        currentChapterPageNumber: maps[i]['currentChapterPageNumber'],
        currentTxtFontSize: maps[i]['currentTxtFontSize'],
        totalReadProgress: maps[i]['totalReadProgress'],
        lastReadDatetime: maps[i]['lastReadDatetime'],
      );
    });
  }

  // 获取 UserTxtState 表中的所有数据
  Future<List<UserTxtState>> readUserTxtState() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
        await db.query(SqliteSqlStatements.tableNameOfUserTxtState);

    //将 List<Map<String, dynamic> 转换成 List<> 数据类型
    return List.generate(maps.length, (i) {
      return UserTxtState(
        userTxTStateId: maps[i]['userTxTStateId'],
        txtId: maps[i]['txtId'],
        currentChapterId: maps[i]['currentChapterId'],
        currentChapterPageNumber: maps[i]['currentChapterPageNumber'],
        currentTxtFontSize: maps[i]['currentTxtFontSize'],
        totalReadProgress: maps[i]['totalReadProgress'],
        lastReadDatetime: maps[i]['lastReadDatetime'],
      );
    });
  }
}
