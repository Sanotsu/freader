import 'package:flutter/material.dart';
// import 'package:just_audio_background/just_audio_background.dart';

import 'layout/app.dart';

// void main() {
//   runApp(const FreaderApp());
// }
Future<void> main() async {
  // 这一堆是为了能够背景播放音乐
  // await JustAudioBackground.init(
  //   androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
  //   androidNotificationChannelName: 'Audio playback',
  //   androidNotificationOngoing: true,
  // );
  runApp(const FreaderApp());
}
