// ignore_for_file: avoid_print

import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:freader/common/personal/constants.dart';
import 'package:freader/common/utils/sqlite_audio_helper.dart';
import 'package:freader/models/app_embedded/local_audio_state.dart';
import 'package:freader/views/tools_view/audio_player_category/audio_player_widget/fetch_audio_data.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';

import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';

import 'audio_player_widget/commons.dart';

class AudioPlayScreen extends StatefulWidget {
  const AudioPlayScreen({Key? key}) : super(key: key);

  @override
  AudioPlayScreenState createState() => AudioPlayScreenState();
}

class AudioPlayScreenState extends State<AudioPlayScreen> {
  // db工具类
  final AudioDbHelper audioDbHelper = AudioDbHelper();

  // 音频播放类
  late AudioPlayer _player;

  // 当前显示的歌单
  late ConcatenatingAudioSource _playlist;

  // 音频播放页面是否在数据加载中(初始化时肯定是否)
  bool isAudioPageReady = false;

  // 播放列表是否构建完成
  bool isAudioPlaylistReady = true;

  // 所有的歌单信息（供下拉选择）
  List<String> allPlaylist = [];
  List<LocalAudioPlaylist> allDbPlaylist = [];

  // 长按指定歌曲后，弹出新增到歌单中，被选中的歌单
  var selectedPlaylistForAudioAdd = "";

  // 当前歌单的名称（切换时记得修改状态）
  var currentPlaylistName = "";

  // 用来歌曲名搜索的文本框控制器
  final audioSaerchController = TextEditingController();

  // 新增歌单时的歌单名输入框控制器
  final playlistCreateController = TextEditingController();

// test =============================

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.black,
    ));
    initData();
  }

  Future<void> _init() async {
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration.speech());
    // Listen to errors during playback.
    _player.playbackEventStream.listen((event) {},
        onError: (Object e, StackTrace stackTrace) {
      print('A stream error occurred: $e');
    });
  }

  /// 进入音频播放页面初始化数据
  initData() async {
    await _init();

    // audioDbHelper.deleteDb();

    // 1 查看默认歌曲列表是否有歌
    //      有歌，说明之前扫描过，就不扫描了,直接读取默认歌单的数据；
    //      否则，首次使用，扫描全盘，存入默认歌单
    var defaultAudioList = await audioDbHelper.queryLocalAudioInfo();

    // print("defaultAudionList-------${defaultAudionList.length}");

    // === 查看歌单列表
    var tempList = await audioDbHelper.getLocalAudioPlaylist(isFull: false);
    print("^^^^^^^^^^^^^^^^^^${tempList.length}");

    setState(() {
      allDbPlaylist = [];
      allDbPlaylist = tempList;

      allPlaylist = [];
      for (var e in tempList) {
        allPlaylist.add(e.audioPlaylistName);
      }
    });

    print("[[[[[[[[[[[[[[[[[[[[[[${defaultAudioList.length}");
    // db中是否有歌曲存在？有的话，就假装扫描过。（测试：如果没有就默认全盘扫描。但最佳是用户手动扫描）
    if (defaultAudioList.isEmpty) {
      await scanAllLocalAudio();
    }

    // 2 获取默认歌单的数据，构建歌单列表(测试：全盘扫描是，默认名字长度>40的存到了我的最爱)
    List<LocalAudioPlaylist> list = await audioDbHelper.getLocalAudioPlaylist(
      lapId: GlobalConstants.localAudioMyFavoriteId,
    );

    // 初始化时，默认为我的最爱歌单
    currentPlaylistName = GlobalConstants.localAudioMyFavoriteName;

    print("favoriteAudioList ----------- ${list.length}");

    _playlist = await buildPlaylist(list);

    // 3 播放插件绑定播放列表
    try {
      await _player.setAudioSource(_playlist);
      setState(() {
        isAudioPageReady = true;
      });
    } catch (e, stackTrace) {
      // Catch load errors: 404, invalid url ...
      print("Error loading playlist: $e");
      print(stackTrace);
    }
  }

  /// 构建歌单列表信息
  /// 2022-07-17 数据库的歌单信息，没有音频元数据，这里是从数据库取得文件地址，再解析文件地址获取音频元数据
  /// 这会很慢，歌单很长的话就加载巨久，而且还是每次进页面都要加载这么久。
  /// 最好的办法当然是把元数据放到db了，不过这只是个demo，不做这。
  /// 其实db缺少的栏位很多，只是个示例就不强迫了
  buildPlaylist(List<LocalAudioPlaylist> list) async {
    var defaultAlbumArtUrl = "images/tools_image/music-player.jpg";

    List<AudioSource> tempChildren = [];

    // 1 遍历歌单歌曲地址，获取元数据信息，构建列表组件
    for (var i = 0; i < list.length; i++) {
      var ele = list[i];

      // 如果路径为空，直接跳了
      if (ele.audioPath == "") {
        continue;
      }

      var metadata = await MetadataRetriever.fromFile(File(ele.audioPath));

      // 音频元数据额外属性，如果有内嵌专辑图片，就用。没有，预设图篇
      // 还需要保存音频文件在数据库的数据，例如audio的id、name、path等，供移除或者添加到其他歌单时有值可用
      // print("-----------<<<<<<<<$metadata   ---${ele.toJson().toString()} ");
      Map<String, dynamic> cusExtras = {
        "playlistInfo": ele.toJson(),
        "albumArtUrl": defaultAlbumArtUrl,
      };
      if (metadata.albumArt != null) {
        cusExtras.addAll({"albumArtUint8List": metadata.albumArt});
      }

      // 把歌单第一首，列为正在播放的
      if (tempChildren.isEmpty) {
        tempChildren.add(
          ClippingAudioSource(
            // start: const Duration(seconds: 60),
            // end: const Duration(seconds: 90),
            child: AudioSource.uri(
              Uri.parse(metadata.filePath!),
            ),
            tag: MediaItem(
              id: metadata.trackName ??
                  const Uuid().v1() + (metadata.albumName ?? ""),
              artist: metadata.trackArtistNames.toString(),
              album: metadata.albumName,
              title: metadata.trackName ?? ele.audioName,
              extras: cusExtras,
            ),
          ),
        );
        continue;
      }

      // 其他的音频，顺序加入列表组件
      tempChildren.add(
        AudioSource.uri(
          Uri.parse(metadata.filePath!),
          tag: MediaItem(
            id: metadata.trackName ??
                const Uuid().v1() + (metadata.albumName ?? ""),
            artist: metadata.trackArtistNames.toString(),
            album: metadata.albumName,
            title: metadata.trackName ?? ele.audioName,
            extras: cusExtras,
          ),
        ),
      );
    }

    return ConcatenatingAudioSource(children: tempChildren);
  }

  /// 切换主页歌单
  /// 切换后，要查询歌单数据，重新构建歌单列表
  buildSelectPlaylist(String playlistName) async {
    setState(() {
      isAudioPlaylistReady = false;
    });

    if (playlistName == "") {
      return;
    }

    var currentAudionListInfo =
        await audioDbHelper.getLocalAudioPlaylist(lapName: playlistName);
    var temp = await buildPlaylist(currentAudionListInfo);

    setState(() {
      _playlist = temp;
    });

    // 绑定新歌单
    await _player.setAudioSource(_playlist);

    setState(() {
      isAudioPlaylistReady = true;
    });
  }

  /// 按钮弹窗输入搜索歌曲名后，传递歌单名和歌曲名，查询指定歌单是否有歌
  /// 如果有歌，【理应是跳转到该歌单指定位置，但目前能力有限，重新构建只含该歌曲的当前歌单。毕竟关键字搜索，万一很多呢】
  buildAudioSearchPlaylist(String playlistName, String audioName) async {
    setState(() {
      isAudioPlaylistReady = false;
    });

    if (playlistName == "") {
      return;
    }

    var currentAudionListInfo = await audioDbHelper.getLocalAudioPlaylist(
      lapName: playlistName,
      audioName: audioName,
    );

    print(">>>>>>>$currentAudionListInfo");
    var temp = await buildPlaylist(currentAudionListInfo);

    setState(() {
      _playlist = temp;
    });

    await _player.setAudioSource(_playlist);

    // 查询构建列表后，也要原本的查询输入值
    setState(() {
      isAudioPlaylistReady = true;
      audioSaerchController.text = "";
    });
  }

  /// 新增歌单
  createPlaylist(String playlistName) async {
    // 不管新增结果，都要清空输入框值
    setState(() {
      playlistCreateController.text = "";
    });

    // 1 查询是否已有同名歌单
    var list = await audioDbHelper.getLocalAudioPlaylist(lapName: playlistName);
    if (list.isNotEmpty) {
      Fluttertoast.showToast(msg: "已存在同名歌单!", toastLength: Toast.LENGTH_SHORT);
      return;
    }

    // 2 新增歌单
    var playlistId = const Uuid().v1();

    var lap = LocalAudioPlaylist(
      audioPlaylistId: playlistId,
      audioPlaylistName: playlistName,
      audioId: "",
      audioName: "",
      audioPath: "",
    );

    await audioDbHelper.insertLocalAudioPlaylist(lap);

    // 3 新增成功后，重新查询所有的歌单，并切换当前歌单切换为新增的歌单
    var tempList = await audioDbHelper.getLocalAudioPlaylist(isFull: false);

    setState(() {
      allDbPlaylist = [];
      allDbPlaylist = tempList;

      allPlaylist = [];
      for (var e in tempList) {
        allPlaylist.add(e.audioPlaylistName);
      }
      currentPlaylistName = playlistName;

      // 4 重新构建新歌单的数据
      buildSelectPlaylist(currentPlaylistName);
    });
  }

  /// 删除当前歌单
  deleteCurrentPlaylist() async {
    // 1 删除当前歌单
    await audioDbHelper.deleteLocalAudioPlaylist(name: currentPlaylistName);

    // 2 删除成功后，重新查询所有的歌单，并切换当前歌单切换为新增的歌单（【【【可以抽成一个函数，参数是当前要绑定的列表名称）
    var tempList = await audioDbHelper.getLocalAudioPlaylist(isFull: false);

    setState(() {
      allDbPlaylist = [];
      allDbPlaylist = tempList;

      allPlaylist = [];
      for (var e in tempList) {
        allPlaylist.add(e.audioPlaylistName);
      }
      currentPlaylistName = GlobalConstants.localAudioMyFavoriteName;

      // 3 重新构建新歌单的数据
      buildSelectPlaylist(currentPlaylistName);
    });
  }

  @override
  void dispose() {
    _player.dispose();
    audioSaerchController.dispose();
    super.dispose();
  }

  // 获取当前播放位置音频数据
  Stream<PositionData> get _positionDataStream =>
      Rx.combineLatest3<Duration, Duration, Duration?, PositionData>(
          _player.positionStream,
          _player.bufferedPositionStream,
          _player.durationStream,
          (position, bufferedPosition, duration) => PositionData(
              position, bufferedPosition, duration ?? Duration.zero));

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        // resizeToAvoidBottomInset: false属性会和flutter 官方的监听软键盘高度继承类 WidgetsBindingObserver 相互抵消 注意取舍和业务逻辑判断
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          child: isAudioPageReady
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 预留顶部工具栏（切换到歌单管理、设置、搜索、歌词页等等，但估计都不会去实现）

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        // 歌单管理页面后续还是要做的
                        Padding(
                          padding: EdgeInsets.only(left: 18.0),
                          child: Icon(Icons.list, color: Colors.black),
                        ),
                        // 扫描本地音乐也应该更丰富（默认点击这个按钮就执行全盘扫描）
                        Icon(Icons.manage_search, color: Colors.black),
                        // 本地音乐搜索也跑不了吧（至少需要一个歌单中扫描并能定位到其位置的功能）
                        Icon(Icons.search, color: Colors.black),
                        // 其他的就不管了
                        Padding(
                          padding: EdgeInsets.only(right: 18.0),
                          child: Icon(Icons.lyrics, color: Colors.grey),
                        ),
                      ],
                    ),

                    /// 正在播放的音频区域
                    _buildCurrentPlayArea(_player),

                    /// 音频控制按钮区域
                    ControlButtons(_player),

                    /// 音频拖动进度条
                    StreamBuilder<PositionData>(
                      stream: _positionDataStream,
                      builder: (context, snapshot) {
                        final positionData = snapshot.data;
                        return SeekBar(
                          duration: positionData?.duration ?? Duration.zero,
                          position: positionData?.position ?? Duration.zero,
                          bufferedPosition:
                              positionData?.bufferedPosition ?? Duration.zero,
                          onChangeEnd: (newPosition) {
                            _player.seek(newPosition);
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 8.0),

                    /// 切换播放方式区域(单曲循环等、歌单名称、随机播放图标)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ///> 播放方式切换按钮（单曲循环、列表循环、不循环）
                        StreamBuilder<LoopMode>(
                          stream: _player.loopModeStream,
                          builder: (context, snapshot) {
                            final loopMode = snapshot.data ?? LoopMode.off;
                            const icons = [
                              Icon(Icons.repeat, color: Colors.grey),
                              Icon(Icons.repeat, color: Colors.orange),
                              Icon(Icons.repeat_one, color: Colors.orange),
                            ];
                            const cycleModes = [
                              LoopMode.off,
                              LoopMode.all,
                              LoopMode.one,
                            ];
                            final index = cycleModes.indexOf(loopMode);
                            return IconButton(
                              icon: icons[index],
                              onPressed: () {
                                _player.setLoopMode(cycleModes[
                                    (cycleModes.indexOf(loopMode) + 1) %
                                        cycleModes.length]);
                              },
                            );
                          },
                        ),

                        ///> 删除当前歌单的icon按钮
                        IconButton(
                          icon: const Icon(Icons.remove),
                          color: Colors.blue,
                          tooltip: '删除当前歌单',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // 后续这些dialog等通用配置可以单独列，不要这样到处size都不同
                                return AlertDialog(
                                  title: Text(
                                    "确认删除(预设歌单不可删)?",
                                    style: TextStyle(fontSize: 18.sp),
                                  ),
                                  content: Text(currentPlaylistName),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '取消',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                    TextButton(
                                      // 如果要被删除的歌单是默认歌单，缺点按钮不可点击
                                      onPressed: (currentPlaylistName ==
                                                  GlobalConstants
                                                      .localAudioMyFavoriteName ||
                                              currentPlaylistName ==
                                                  GlobalConstants
                                                      .localAudioDeaultPlaylistName)
                                          ? null
                                          : () async {
                                              deleteCurrentPlaylist();

                                              Navigator.of(context).pop();
                                            },
                                      child: Text(
                                        '确定',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        ///> 歌单名称（这里我想弄一个点击下拉切换到不同的歌单的功能，切换之后要重新渲染歌单）
                        SizedBox(
                          width: 160.sp,
                          child: DropdownSearch<String>(
                            // 单模式弹出窗口的自定义道具
                            popupProps: PopupProps.menu(
                              showSelectedItems: true,
                              disabledItemFn: (String s) => s.startsWith('I'),
                              // 默认是 FlexFit.tight，填满所有可用空间，改为loose，则只显示已占用高度
                              fit: FlexFit.loose,
                            ),
                            items: allPlaylist,
                            onChanged: (playlistName) {
                              setState(() {
                                currentPlaylistName = playlistName ?? "";
                              });

                              buildSelectPlaylist(playlistName ?? "");
                            },
                            // 音乐播放主页默认是我的最爱列表，这里的值注意和initData一致
                            selectedItem: currentPlaylistName,
                          ),
                        ),

                        ///> 添加歌单的icon按钮
                        IconButton(
                          icon: const Icon(Icons.add),
                          color: Colors.blue,
                          tooltip: '新建歌单',
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // 后续这些dialog等通用配置可以单独列，不要这样到处size都不同
                                return AlertDialog(
                                  title: Text(
                                    "搜索歌单名:",
                                    style: TextStyle(fontSize: 18.sp),
                                  ),
                                  content: TextField(
                                    controller: playlistCreateController,
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '取消',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        print(
                                            "-------playlistCreateController---${playlistCreateController.text}");

                                        createPlaylist(
                                            playlistCreateController.text);

                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        '确定',
                                        style: TextStyle(fontSize: 14.sp),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        ),

                        ///> 随机播放的图标按钮
                        StreamBuilder<bool>(
                          stream: _player.shuffleModeEnabledStream,
                          builder: (context, snapshot) {
                            final shuffleModeEnabled = snapshot.data ?? false;
                            return IconButton(
                              icon: shuffleModeEnabled
                                  ? const Icon(Icons.shuffle,
                                      color: Colors.orange)
                                  : const Icon(Icons.shuffle,
                                      color: Colors.grey),
                              onPressed: () async {
                                final enable = !shuffleModeEnabled;
                                if (enable) {
                                  await _player.shuffle();
                                }
                                await _player.setShuffleModeEnabled(enable);
                              },
                            );
                          },
                        ),
                      ],
                    ),

                    /// 具体当前播放列表区域
                    /// 左右滑动从列表移除（但没有从db移除）
                    _buildPlaylistArea(_player, _playlist),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator()), // 加载列表时默认是个圈，有其他东西代替更好了
        ),

        /// 歌单管理不放在当前组件，这里改为搜索当前歌单指定歌曲
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.search),

          /// 点击搜索按钮，查看本歌单
          /// (只为了搜索demo，如果查询所有的话，不在当前歌单怎么办？直接跳到默认？先不想这个逻辑，只为了实现搜索。后续要改，再改)
          onPressed: () {
            print("-------currentPlaylistName---$currentPlaylistName");

            showDialog(
              context: context,
              builder: (BuildContext context) {
                // 后续这些dialog等通用配置可以单独列，不要这样到处size都不同
                return AlertDialog(
                  title: Text(
                    "搜索歌曲名:",
                    style: TextStyle(fontSize: 18.sp),
                  ),
                  content: TextField(
                    controller: audioSaerchController,
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '取消',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        print(
                            "-------audioSaerchController---${audioSaerchController.text}");

                        buildAudioSearchPlaylist(
                            currentPlaylistName, audioSaerchController.text);

                        Navigator.of(context).pop();
                      },
                      child: Text(
                        '确定',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  /// 正在播放的音频区域函数
  _buildCurrentPlayArea(_player) {
    return Expanded(
      child: StreamBuilder<SequenceState?>(
        stream: _player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state?.sequence.isEmpty ?? true) {
            return const SizedBox();
          }
          final metadata = state!.currentSource!.tag as MediaItem;

          // print(">>>>>>>>>>>.........>>>>>>>>$metadata");

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    // 有内嵌专辑封面信息，就显示，没有就空白占位
                    child: ((metadata.extras)?["albumArtUint8List"] != null)
                        ? Image.memory(
                            metadata.extras!["albumArtUint8List"],
                            height: MediaQuery.of(context).size.height >
                                    MediaQuery.of(context).size.width
                                ? MediaQuery.of(context).size.width
                                : 256.0,
                            width: MediaQuery.of(context).size.height >
                                    MediaQuery.of(context).size.width
                                ? MediaQuery.of(context).size.width
                                : 256.0,
                          )
                        : Image.asset(
                            metadata.extras!["albumArtUrl"],
                            height: MediaQuery.of(context).size.height >
                                    MediaQuery.of(context).size.width
                                ? MediaQuery.of(context).size.width
                                : 256.0,
                            width: MediaQuery.of(context).size.height >
                                    MediaQuery.of(context).size.width
                                ? MediaQuery.of(context).size.width
                                : 256.0,
                          ),
                  ),
                ),
              ),
              Text(metadata.title,
                  style: Theme.of(context).textTheme.headline6),
              Text(metadata.album ?? ""),
            ],
          );
        },
      ),
    );
  }

  /// 构建播放列表区域
  _buildPlaylistArea(AudioPlayer _player, ConcatenatingAudioSource _playlist) {
    return SizedBox(
      height: 240.0,
      child: StreamBuilder<SequenceState?>(
        stream: _player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          final sequence = state?.sequence ?? [];
          // ReorderableListView 拖拽排序组件
          if (isAudioPlaylistReady) {
            return ReorderableListView(
              // 拖拽排序后的回调函数
              onReorder: (int oldIndex, int newIndex) {
                if (oldIndex < newIndex) newIndex--;
                _playlist.move(oldIndex, newIndex);
              },
              // 拖动的子组件
              children: [
                for (var i = 0; i < sequence.length; i++)
                  // 滑动清除组件  Dismissible（从列表中移除）
                  GestureDetector(
                    key: ValueKey(sequence[i]),
                    child: Container(
                      alignment: Alignment.center,
                      color: Colors.blue,
                      child: Dismissible(
                        key: ValueKey(sequence[i]),
                        background: Container(
                          color: Colors.redAccent,
                          alignment: Alignment.centerRight,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                        onDismissed: (dismissDirection) {
                          _playlist.removeAt(i);
                        },
                        // 歌单列表显示的内容（音频名称、歌手名、专辑名等）
                        child: Material(
                          color: i == state!.currentIndex
                              ? Colors.grey.shade300
                              : null,
                          child: ListTile(
                            title: Text(sequence[i].tag.title as String),
                            subtitle: Text(
                                "${sequence[i].tag?.artist}---${sequence[i].tag?.album}"),
                            onTap: () {
                              // 点击跳转指定歌曲位置
                              _player.seek(Duration.zero, index: i);
                            },
                          ),
                        ),
                      ),
                    ),

                    //长按指定歌曲，弹窗供加入指定别的歌单
                    onLongPress: () {
                      // 在音频元数据的 extras属性中有存入对应其db信息，取出来，转型
                      var selectedAudioInPlaylist = LocalAudioPlaylist.fromJson(
                          (sequence[i].tag.extras['playlistInfo']));

                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // 后续这些dialog等通用配置可以单独列，不要这样到处size都不同
                          return AlertDialog(
                            title: Text(
                              "添加到歌单:",
                              style: TextStyle(fontSize: 18.sp),
                            ),
                            content: SizedBox(
                              width: 200.sp,
                              child: DropdownSearch<String>(
                                // 自定义样式
                                popupProps: const PopupProps.menu(
                                  // 默认是 FlexFit.tight，填满所有可用空间，改为loose，则只显示已占用高度
                                  fit: FlexFit.loose,
                                ),
                                items: allPlaylist,
                                onChanged: (el) {
                                  setState(() {
                                    selectedPlaylistForAudioAdd = el ?? "";
                                  });
                                },
                                selectedItem: allPlaylist[0],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  '取消',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  // 选择了需要添加的歌单之后，取得其歌单的id信息
                                  // 这里必然是存在的（没有bug的话），所以不做其他检查了
                                  var selectPlaylist = allDbPlaylist.where(
                                      (row) => (row.audioPlaylistName ==
                                          selectedPlaylistForAudioAdd));

                                  //点击确定之后，
                                  //如果已存在，则不新增。否则，新增
                                  var alreadyList = await audioDbHelper
                                      .checkIsAudioInPlaylist(
                                    selectPlaylist.first.audioPlaylistId,
                                    selectedAudioInPlaylist.audioId,
                                  );

                                  //如果不存在，把当前音频添加到选中的歌单去（新增db row）
                                  if (alreadyList <= 0) {
                                    await audioDbHelper
                                        .insertLocalAudioPlaylist(
                                            LocalAudioPlaylist(
                                                audioPlaylistId: selectPlaylist
                                                    .first.audioPlaylistId,
                                                audioPlaylistName:
                                                    selectedPlaylistForAudioAdd,
                                                audioId: selectedAudioInPlaylist
                                                    .audioId,
                                                audioName:
                                                    selectedAudioInPlaylist
                                                        .audioName,
                                                audioPath:
                                                    selectedAudioInPlaylist
                                                        .audioPath));
                                  }
                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  '确定',
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
              ],
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}

/// 当前歌曲控制按钮具体实现
/// 音量、上一曲、暂停/播放、下一曲、倍速
class ControlButtons extends StatelessWidget {
  final AudioPlayer player;

  const ControlButtons(this.player, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: const Icon(Icons.volume_up),
          onPressed: () {
            showSliderDialog(
              context: context,
              title: "音量调节",
              divisions: 10,
              min: 0.0,
              max: 1.0,
              stream: player.volumeStream,
              onChanged: player.setVolume,
            );
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_previous),
            onPressed: player.hasPrevious ? player.seekToPrevious : null,
          ),
        ),
        StreamBuilder<PlayerState>(
          stream: player.playerStateStream,
          builder: (context, snapshot) {
            final playerState = snapshot.data;
            final processingState = playerState?.processingState;
            final playing = playerState?.playing;
            if (processingState == ProcessingState.loading ||
                processingState == ProcessingState.buffering) {
              return Container(
                margin: const EdgeInsets.all(8.0),
                width: 64.0,
                height: 64.0,
                child: const CircularProgressIndicator(),
              );
            } else if (playing != true) {
              return IconButton(
                icon: const Icon(Icons.play_arrow),
                iconSize: 64.0,
                onPressed: player.play,
              );
            } else if (processingState != ProcessingState.completed) {
              return IconButton(
                icon: const Icon(Icons.pause),
                iconSize: 64.0,
                onPressed: player.pause,
              );
            } else {
              return IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 64.0,
                onPressed: () => player.seek(Duration.zero,
                    index: player.effectiveIndices!.first),
              );
            }
          },
        ),
        StreamBuilder<SequenceState?>(
          stream: player.sequenceStateStream,
          builder: (context, snapshot) => IconButton(
            icon: const Icon(Icons.skip_next),
            onPressed: player.hasNext ? player.seekToNext : null,
          ),
        ),
        StreamBuilder<double>(
          stream: player.speedStream,
          builder: (context, snapshot) => IconButton(
            icon: Text("${snapshot.data?.toStringAsFixed(1)}x",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            onPressed: () {
              showSliderDialog(
                context: context,
                title: "倍速调节",
                divisions: 10,
                min: 0.5,
                max: 1.5,
                stream: player.speedStream,
                onChanged: player.setSpeed,
              );
            },
          ),
        ),
      ],
    );
  }
}
