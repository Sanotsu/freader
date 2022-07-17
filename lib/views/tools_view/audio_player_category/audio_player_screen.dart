// ignore_for_file: avoid_print

import 'dart:io';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
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

  // 音频播放页面是否在数据加载中
  bool isAudioNotReady = true;

// test =============================
// 往歌单新加默认asset音频的测试需要的索引初始值
  static int _nextMediaId = 0;

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

    audioDbHelper.deleteDb();

    // 1 查看默认歌曲列表是否有歌
    //      有歌，说明之前扫描过，就不扫描了,直接读取默认歌单的数据；
    //      否则，首次使用，扫描全盘，存入默认歌单
    var defaultAudionList = await audioDbHelper.queryLocalAudioInfo();

    print("defaultAudionList${defaultAudionList.length}");

    var favoriteAudionList = await audioDbHelper.getLocalAudioPlaylist(
      lapId: GlobalConstants.localAudioMyFavoriteId,
    );

    print("favoriteAudionList ${favoriteAudionList.length}");

    // 为什么小于1？因为有默认全局歌单这么一条初始值
    if (defaultAudionList.length <= 1) {
      print("9999999999999999");
      await scanAllLocalAudio();
      print("9999999999999999999");
    }
    print("7777777777777777");

    // 2 获取默认歌单的数据，构建歌单列表
    List<LocalAudioPlaylist> list = await audioDbHelper.getLocalAudioPlaylist(
      lapId: GlobalConstants.localAudioDeaultPlaylistId,
    );

    print("0000000000000$list");

    _playlist = await buildPlaylist(list);

    print("1111111$_playlist");

    // 3 播放插件绑定播放列表
    try {
      print("22222222222$_playlist");

      await _player.setAudioSource(_playlist);
      setState(() {
        isAudioNotReady = false;
      });

      print("333333$_playlist");
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
    print("aaaaaaaaaaaaaaaaaaaaaaaaaa${list.length}");

    var defaultAlbumArtUrl = "images/tools_image/music-player.jpg";

    List<AudioSource> tempChildren = [];

    // 1 遍历歌单歌曲地址，获取元数据信息，构建列表组件
    for (var i = 1; i < list.length; i++) {
      var ele = list[i];

      var metadata = await MetadataRetriever.fromFile(File(ele.audioPath));

      // 如果路径为空，直接跳了
      if (metadata.filePath == null) {
        continue;
      }

      // 音频元数据额外属性，如果有内嵌专辑图片，就用。没有，预设图篇
      print("-----------<<<<<<<<$metadata ");
      Map<String, dynamic> ex = {"albumArtUrl": defaultAlbumArtUrl};
      if (metadata.albumArt != null) {
        ex = {"albumArtUint8List": metadata.albumArt};
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
              extras: ex,
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
            extras: ex,
          ),
        ),
      );
    }

    return ConcatenatingAudioSource(children: tempChildren);
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

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
        body: SafeArea(
          child: isAudioNotReady
              ? const Center(
                  child: CircularProgressIndicator()) // 加载列表时默认是个圈，有其他东西代替更好了
              : Column(
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
                    buildCurrent(_player),

                    /// 音频控制按钮区域
                    ControlButtons(_player),
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
                      children: [
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
                        // 歌单名称（这里我想弄一个点击下拉切换到不同的歌单的功能，切换之后要重新渲染歌单）
                        Expanded(
                          child: Text(
                            "Playlist",
                            style: Theme.of(context).textTheme.headline6,
                            textAlign: TextAlign.center,
                          ),
                        ),
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
                    SizedBox(
                      height: 240.0,
                      child: StreamBuilder<SequenceState?>(
                        stream: _player.sequenceStateStream,
                        builder: (context, snapshot) {
                          final state = snapshot.data;
                          final sequence = state?.sequence ?? [];
                          // ReorderableListView 拖拽排序组件
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
                                Dismissible(
                                  key: ValueKey(sequence[i]),
                                  background: Container(
                                    color: Colors.redAccent,
                                    alignment: Alignment.centerRight,
                                    child: const Padding(
                                      padding: EdgeInsets.only(right: 8.0),
                                      child: Icon(Icons.delete,
                                          color: Colors.white),
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
                                      title:
                                          Text(sequence[i].tag.title as String),
                                      subtitle: Text(
                                          "${sequence[i].tag?.artist}---${sequence[i].tag?.album}"),
                                      onTap: () {
                                        // 点击跳转指定歌曲位置
                                        _player.seek(Duration.zero, index: i);
                                      },
                                    ),
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    ),
                  ],
                ),
        ),

        /// 测试：新增歌曲到当前歌单的悬空按钮
        /// 歌单管理不放在当前组件，这里改为搜索当前歌单？
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            _playlist.add(AudioSource.uri(
              Uri.parse("asset:///assets/audio/nature.mp3"),
              tag: MediaItem(
                id: '${_nextMediaId++}',
                album: "(demo)Public Domain",
                title: "(demo)Nature Sounds $_nextMediaId",
                extras: {"albumArtUrl": "images/tools_image/music-player.jpg"},
              ),
            ));
          },
        ),
      ),
    );
  }

  /// 正在播放的音频区域函数
  buildCurrent(_player) {
    return Expanded(
      child: StreamBuilder<SequenceState?>(
        stream: _player.sequenceStateStream,
        builder: (context, snapshot) {
          final state = snapshot.data;
          if (state?.sequence.isEmpty ?? true) {
            return const SizedBox();
          }
          final metadata = state!.currentSource!.tag as MediaItem;

          print(".........>>>>>>>>${metadata.extras}");
          print(">>>>>>>>>>>.........>>>>>>>>$metadata");

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
              title: "Adjust volume",
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
                title: "Adjust speed",
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
