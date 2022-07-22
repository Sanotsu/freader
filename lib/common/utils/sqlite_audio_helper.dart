// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:convert';
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
    await db.execute(SqliteSqlStatements.createTable4LocalPlaylistHasAudio);
// 在新建歌单表时，一并初始化几条默认歌单数据，用于扫描结果默认放置的位置
    var initDefaultLapRow = LocalAudioPlaylist(
      playlistId: GlobalConstants.localAudioDeaultPlaylistId,
      playlistName: GlobalConstants.localAudioDeaultPlaylistName,
    );

    var initMyFavoriteLapRow = LocalAudioPlaylist(
      playlistId: GlobalConstants.localAudioMyFavoriteId,
      playlistName: GlobalConstants.localAudioMyFavoriteName,
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
    print("开始删除內嵌的sqlite db文件 ${SqliteSqlStatements.audioDbName}");

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
  // 如果有传id\name\path,只有name为可模糊查询
  Future<List<LocalAudioInfo>> queryLocalAudioInfo({
    String? audioId,
    String? audioName,
    String? audioPath,
  }) async {
    Database db = await database;

    // 根据传入参数，构建查询条件
    var where = "";
    var whereArgs = [];
    if (audioId != null) {
      where += " audioId = ? and";
      whereArgs.add(audioId);
    }
    if (audioName != null) {
      where += " audioName like ? and";
      whereArgs.add('%$audioName%');
    }

    if (audioPath != null) {
      where += " audioPath = ? and";
      whereArgs.add(audioPath);
    }

    // 因为不知道传入的id是都有还是只有一个，先传的那个，所以 where 最后都有个and,作为条件是，要先去掉
    var realWhere = where;
    if (where.endsWith("and")) {
      realWhere = where.substring(0, where.length - 4);
    }

    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfLocalAudioInfo,
      where: realWhere != "" ? realWhere : null, // null查询所有
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null, // null 返回所有行
    );

    return List.generate(maps.length, (i) {
      return LocalAudioInfo(
        audioId: maps[i]['audioId'],
        audioName: maps[i]['audioName'],
        audioPath: maps[i]['audioPath'],
        artist: maps[i]['artist'],
        album: maps[i]['album'],
        displayTitle: maps[i]['displayTitle'],
        extras: {"metadata": jsonDecode(maps[i]['extras'])},
      );
    });
  }

  ///================歌单列表信息表操作 （为了简单，都是Row级别）

  // 新增歌单(已经包含新增歌单本身，和指定歌单新增指定歌曲)
  Future<int> insertLocalAudioPlaylist(LocalAudioPlaylist lap) async {
    Database db = await database;
    // insert返回最后插入行的id
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      lap.toMap(),
    );
    return result;
  }

  // 查询歌单基本信息
  // 如果有传id\name和音频name，有name为可模糊查询
  Future<List<LocalAudioPlaylist>> queryLocalAudioPlaylist({
    String? lapId,
    String? lapName,
  }) async {
    Database db = await database;

    // 根据传入参数，构建查询条件
    var where = "";
    var whereArgs = [];
    if (lapId != null) {
      where += " playlistId = ? and";
      whereArgs.add(lapId);
    }
    if (lapName != null) {
      where += " playlistName like ? and";
      whereArgs.add('%$lapName%');
    }

    // 因为不知道传入的id是都有还是只有一个，先传的那个，所以 where 最后都有个and,作为条件是，要先去掉
    var realWhere = where;
    if (where.endsWith("and")) {
      realWhere = where.substring(0, where.length - 4);
    }

    List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      where: realWhere != "" ? realWhere : null, // null查询所有
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null, // null 返回所有行
    );

    return List.generate(maps.length, (i) {
      return LocalAudioPlaylist(
        playlistId: maps[i]['playlistId'],
        playlistName: maps[i]['playlistName'],
        playlistDescription: maps[i]['playlistDescription'],
        playlistTag: maps[i]['playlistTag'],
        extras: {
          "cusExtras": jsonDecode(maps[i]['extras'] ?? "{}")
        }, // 2022-07-22 歌单的额外信息，现在还不知道放啥
      );
    });
  }

  // 删除歌单
  Future<int> deleteLocalAudioPlaylist({String? id, String? name}) async {
    // 根据传入参数，构建查询条件
    var where = "";
    var whereArgs = [];
    if (id != null) {
      where += " playlistId = ? and";
      whereArgs.add(id);
    }
    if (name != null) {
      where += " playlistName = ? and";
      whereArgs.add(name);
    }

    if (name == null && id == null) {
      where = " playlistId = ? and";
      whereArgs = ["无效删除"];
    }

    // 因为不知道传入的id是都有还是只有一个，先传的那个，所以 where 最后都有个and,作为条件是，要先去掉
    var realWhere = where;
    if (where.endsWith("and")) {
      realWhere = where.substring(0, where.length - 4);
    }

    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfLocalAudioPlaylist,
      where: realWhere,
      whereArgs: whereArgs,
    );
    return result;
  }

  //========================歌单音频管理 (新增删除都是row级别))

  // 新增歌单(已经包含新增歌单本身，和指定歌单新增指定歌曲)
  Future<int> insertLocalPlaylistHasAudio(LocalPlaylistHasAudio lpha) async {
    Database db = await database;
    // insert返回最后插入行的id
    var result = await db.insert(
      SqliteSqlStatements.tableNameOfLocalPlaylistHasAudio,
      lpha.toMap(),
    );
    return result;
  }

  /*
{metadata: {
  trackName: 他一定很爱你, trackArtistNames: [阿杜], 
  albumName: 天黑, albumArtistName: null, trackNumber: null, 
  albumLength: null, year: null, genre: null, authorName: null, writerName: null, discNumber: null, 
  mimeType: audio/mpeg, trackDuration: 214805, bitrate: 320000, filePath: /storage/emulated/0/Music/test/阿杜 - 他一定很爱你.mp3},
   playlistHasAudio: {
    localPlaylistHasAudioId: 719b78f0-09d2-11ed-9e34-f5c4eebf42fd, playlistId: deaultPlaylist, 
    audioId: 719b03c0-09d2-11ed-9e34-f5c4eebf42fd, playlistName: 默认全盘歌单, 
audioName: 阿杜 - 他一定很爱你.mp3, audioPath: /storage/emulated/0/Music/test/阿杜 - 他一定很爱你.mp3,
 extras: {...}}}
  */

  /// 获取指定歌单的音频信息列表
  /// 指定歌单编号、模糊歌单名称、模糊查询歌曲存在于哪些歌单中
  Future<List<LocalPlaylistHasAudio>> getLocalPlaylistHasAudio({
    String? lapId,
    String? lapName,
    String? audioName,
  }) async {
    final db = await database;
    // 根据传入参数，构建查询条件
    var where = "";
    var whereArgs = [];

    // 有传id或者name，或者两者都传，拼好条件
    if (lapId != null) {
      where += " playlistId = ? and";
      whereArgs.add(lapId);
    }
    if (lapName != null) {
      where += " playlistName = ? and";
      whereArgs.add(lapName);
    }
    if (audioName != null) {
      where += " audioName like ? and";
      whereArgs.add('%$audioName%');
    }

    // 因为不知道传入的id是都有还是只有一个，先传的那个，所以 where 最后都有个and,作为条件是，要先去掉
    var realWhere = where;
    if (where.endsWith("and")) {
      realWhere = where.substring(0, where.length - 4);
    }

    final List<Map<String, dynamic>> maps = await db.query(
      SqliteSqlStatements.tableNameOfLocalPlaylistHasAudio,
      distinct: true,
      where: realWhere != "" ? realWhere : null,
      whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
    );

    //将 List<Map<String, dynamic> 转换成 List<> 数据类型
    return List.generate(maps.length, (i) {
      return LocalPlaylistHasAudio(
        localPlaylistHasAudioId: maps[i]['localPlaylistHasAudioId'],
        playlistId: maps[i]['playlistId'],
        audioId: maps[i]['audioId'] ?? "",
        playlistName: maps[i]['playlistName'],
        audioName: maps[i]['audioName'] ?? "",
        audioPath: maps[i]['audioPath'] ?? "",
        extras: {"metadata": jsonDecode(maps[i]['extras'])},
      );
    });
  }

  // 删除指定歌单指定歌曲（通过audioId）
  Future<int> removeAudioFromLocalAudioPlaylist(
    String lapId,
    String audioId,
  ) async {
    Database db = await database;
    var result = await db.delete(
      SqliteSqlStatements.tableNameOfLocalPlaylistHasAudio,
      where: "playlistId=? and audioId=?",
      whereArgs: [lapId, audioId],
    );
    return result;
  }

// 查询指定音频在指定歌单中是否存在
  Future<int> checkIsAudioInPlaylist(
    String lapId,
    String audioId,
  ) async {
    Database db = await database;
    var result = await db.query(
      SqliteSqlStatements.tableNameOfLocalPlaylistHasAudio,
      where: "playlistId=? and audioId=?",
      whereArgs: [lapId, audioId],
    );
    return result.length;
  }

  // 【通过名称】查询指定音频在指定歌单中是否存在
  //      比如扫描音频的时候，只有扫描的文件名和下拉选择的歌单名，没有id
  //      配合上一个函数，也多一个用name匹配的
  Future<int> checkIsAudioInPlaylistByName(
    String lapName,
    String audioName,
  ) async {
    Database db = await database;
    var result = await db.query(
      SqliteSqlStatements.tableNameOfLocalPlaylistHasAudio,
      where: "playlistName=? and audioName=?",
      whereArgs: [lapName, audioName],
    );
    return result.length;
  }
}
