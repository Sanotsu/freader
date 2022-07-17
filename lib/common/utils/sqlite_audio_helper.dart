// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:freader/common/personal/constants.dart';
import 'package:freader/common/utils/sqlite_sql_statements.dart';
import 'package:freader/models/app_embedded/local_audio_state.dart';

import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class AudioDbHelper {
  static final AudioDbHelper _audioDbHelper = AudioDbHelper._createInstance();
  static Database? _database;

// 命名的构造函数用于创建DatabaseHelper的实例
  AudioDbHelper._createInstance();

  factory AudioDbHelper() {
    return _audioDbHelper;
  }

  Future<Database> get database async =>
      _database ??= await initializeDatabase();

  /// 初始化数据库
  Future<Database> initializeDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + "/" + SqliteSqlStatements.audioDbName;

    print("111111111111111111111$path");

    // Open/create the database at a given path
    var notesDatabase =
        await openDatabase(path, version: 1, onCreate: _createDb);
    return notesDatabase;
  }

  // 创建表
  void _createDb(Database db, int newVersion) async {
    await db.execute(SqliteSqlStatements.createTable4LocalAudioInfo);
    await db.execute(SqliteSqlStatements.createTable4LocalAudioPlaylist);
// 在新建歌单表时，一并初始化几条默认歌单数据，用于扫描结果默认放置的位置
    var initDefaultLapRow = LocalAudioPlaylist(
      audioPlaylistId: GlobalConstants.localAudioDeaultPlaylistId,
      audioPlaylistName: GlobalConstants.localAudioDeaultPlaylistName,
      audioId: "",
      audioName: "",
      audioPath: "",
    );

    var initMyFavoriteLapRow = LocalAudioPlaylist(
      audioPlaylistId: GlobalConstants.localAudioMyFavoriteId,
      audioPlaylistName: GlobalConstants.localAudioMyFavoriteId,
      audioId: "",
      audioName: "",
      audioPath: "",
    );

    // 插入多条
    var batch = db.batch();
    batch.insert(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      initDefaultLapRow.toMap(),
    );
    batch.insert(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      initMyFavoriteLapRow.toMap(),
    );
    await batch.commit(noResult: true);

    //  插入单条
    // await db.insert(
    //   SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
    //   initDefaultLapRow.toMap(),
    // );
  }

  // 关闭数据库
  Future<bool> closeDatabase() async {
    Database db = await database;

    print("db.isOpen ${db.isOpen}");
    await db.close();
    print("db.isOpen ${db.isOpen}");

    // 删除db或者关闭db都需要重置db为null，
    // 否则后续会保留之前的连接，以致出现类似错误：Unhandled Exception: DatabaseException(database_closed 5)
    // https://github.com/tekartik/sqflite/issues/223
    _database = null;

    // 如果已经关闭了，返回ture
    if (!db.isOpen) {
      return true;
    } else {
      return false;
    }
  }

  // 删除sqlite的db文件（初始化数据库操作中那个path的值）
  void deleteDb() async {
    print("开始删除內嵌的sqlite db文件");

    // 删除db或者关闭db都需要重置db为null，
    // 否则后续会保留之前的连接，以致出现类似错误：Unhandled Exception: DatabaseException(database_closed 5)
    // https://stackoverflow.com/questions/60848752/delete-database-when-log-out-and-create-again-after-log-in-dart
    _database = null;

    await deleteDatabase(
      "/data/user/0/com.example.freader/app_flutter/${SqliteSqlStatements.audioDbName}",
    );
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

  ///================音频信息表操作 （为了简单，都是Row级别）
  // audioInfo 插入数据
  Future<int> insertLocalAudioInfo(LocalAudioInfo lai) async {
    Database db = await database;
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfLocalAudioInfo,
      lai.toMap(),
    );
    return result;
  }

  // pdfState 删除数据
  Future<int> deleteLocalAudioInfo(String id) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfLocalAudioInfo,
      where: "audioId=?",
      whereArgs: [id],
    );
    return result;
  }

  /// 查询音频信息
  // 如果有传id，用id精确查；有传name，用name模糊查；都没有，查所有。
  Future<List<LocalAudioInfo>> queryLocalAudioInfo({
    String? audioId,
    String? audioName,
  }) async {
    Database db = await database;

    // 根据传入参数，构建查询条件
    var where = "";
    var whereArgs = [];
    if (audioId != null) {
      where = "audioId = ?";
      whereArgs = [audioId];
    } else if (audioName != null) {
      where = "audioName = ?";
      whereArgs = [audioName];
    } else {
      where = "audioId != ?";
      whereArgs = ["!0"];
    }

    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfLocalAudioInfo,
      where: where,
      whereArgs: whereArgs,
    );

    return List.generate(maps.length, (i) {
      return LocalAudioInfo(
        audioId: maps[i]['audioId'],
        audioName: maps[i]['audioName'],
        audioPath: maps[i]['audioPath'],
      );
    });
  }

  ///================歌单列表信息表操作 （为了简单，都是Row级别）

  // 新增歌单(已经包含新增歌单本身，和指定歌单新增指定歌曲)
  Future<int> insertLocalAudioPlaylist(LocalAudioPlaylist lap) async {
    Database db = await database;
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      lap.toMap(),
    );
    return result;
  }

  // 删除歌单
  Future<int> deleteLocalAudioPlaylist(String id) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      where: "audioPlaylistId=?",
      whereArgs: [id],
    );
    return result;
  }

  // 删除指定歌单指定歌曲（通过audioId）
  Future<int> removeAudioFromLocalAudioPlaylist(
    String lapId,
    String audioId,
  ) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      where: "audioPlaylistId=? and audioId=?",
      whereArgs: [lapId, audioId],
    );
    return result;
  }

  /// 获取歌单信息
  // 有歌单id、歌单name或者不传，都查询符合条件的含歌曲的完整歌单
  // 如果isFull为false，则不需要歌单里面的歌曲，只是查有几张歌单，获取id之类的，用于添加歌曲等
  Future<List<LocalAudioPlaylist>> getLocalAudioPlaylist({
    String? lapId,
    String? lapName,
    bool? isFull,
  }) async {
    final db = await database;

    // 根据传入参数，构建查询条件
    var where = "";
    var whereArgs = [];
    var columns = [
      "audioPlaylistId",
      "audioPlaylistName",
      "audioId",
      "audioName",
      "audioPath",
    ];

    if (lapId != null) {
      where = "audioPlaylistId = ?";
      whereArgs = [lapId];
    } else if (lapName != null) {
      where = "audioPlaylistName = ?";
      whereArgs = [lapName];
    } else {
      where = "audioPlaylistId != ?";
      whereArgs = [""];
    }

    if (isFull = false) {
      columns = ["audioPlaylistId", "audioPlaylistName"];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      columns: columns,
      where: where,
      whereArgs: whereArgs,
    );

    //将 List<Map<String, dynamic> 转换成 List<> 数据类型
    return List.generate(maps.length, (i) {
      return LocalAudioPlaylist(
        audioId: maps[i]['audioId'],
        audioPlaylistId: maps[i]['audioPlaylistId'],
        audioPlaylistName: maps[i]['audioPlaylistId'],
        audioName: maps[i]['audioName'] ?? "",
        audioPath: maps[i]['audioPath'] ?? "",
      );
    });
  }
}
