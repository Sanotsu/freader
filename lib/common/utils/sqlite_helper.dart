// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:freader/common/utils/sqlite_sql_statements.dart';
import 'package:freader/models/app_embedded/pdf_state.dart';
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
    await db.execute(SqliteSqlStatements.createTable4PdfState);
    await db.execute(SqliteSqlStatements.createTable4Hitokoto);
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

  ///================ 数据库表值对应的操作（为了简单，都是Row级别）
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
      );
    });
  }
}
