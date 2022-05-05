// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_downloader/image_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// 2022-05-05 看起來使用还是比较方便，但android11之后，目前此库无法使用，会出现
/// 类似： java.io.FileNotFoundException: /storage/emulated/0/Download/2022-05-05.05.28.050: open failed: EACCES (Permission denied)
/// android10可以在 main/AndroidManifesrt.xml中添加相关设定，但新的版本不行。
/// 可参看issue：https://github.com/ko2ic/image_downloader/issues/91
/// 
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _message = "";
  String _path = "";
  String _size = "";
  String _mimeType = "";
  File? _imageFile;
  int _progress = 0;

  final List<File> _mulitpleFiles = [];

  @override
  void initState() {
    super.initState();

    ImageDownloader.callback(onProgressUpdate: (String? imageId, int progress) {
      setState(() {
        _progress = progress;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text('Progress: $_progress %'),
                Text(_message),
                Text(_size),
                Text(_mimeType),
                Text(_path),
                _path == ""
                    ? Container()
                    : Builder(
                        builder: (context) => ElevatedButton(
                          onPressed: () async {
                            await ImageDownloader.open(_path)
                                .catchError((error) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                content: Text(
                                    (error as PlatformException).message ?? ''),
                              ));
                            });
                          },
                          child: const Text("Open"),
                        ),
                      ),
                ElevatedButton(
                  onPressed: () {
                    ImageDownloader.cancel();
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _downloadImage(
                        "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/bigsize.jpg");
                  },
                  child: const Text("default destination"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _downloadImage(
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png",
                      destination: AndroidDestinationType.directoryPictures
                        ..inExternalFilesDir()
                        ..subDirectory("sample.gif"),
                    );
                  },
                  child: const Text("custom destination(only android)"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _downloadImage(
                        "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_no.png",
                        whenError: true);
                  },
                  child: const Text("404 error"),
                ),
                ElevatedButton(
                  onPressed: () {
                    _downloadImage(
                        "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.mkv",
                        whenError: true);
                    //_downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.3gp");
                  },
                  child: const Text("unsupported file error(only ios)"),
                ),
                ElevatedButton(
                  onPressed: () {
                    //_downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.mp4");
                    //_downloadImage("https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.m4v");
                    _downloadImage(
                        "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.mov");
                  },
                  child: const Text("movie"),
                ),
                ElevatedButton(
                  onPressed: () async {
                    var list = [
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/bigsize.jpg",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.jpg",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.HEIC",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_transparent.png",
                      "https://raw.githubusercontent.com/wiki/ko2ic/flutter_google_ad_manager/images/sample.gif",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_no.png",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_real_png.jpg",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/bigsize.jpg",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.jpg",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_transparent.png",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_no.png",
                      "https://raw.githubusercontent.com/wiki/ko2ic/flutter_google_ad_manager/images/sample.gif",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter.png",
                      "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/flutter_real_png.jpg",
                    ];

                    List<File> files = [];

                    for (var url in list) {
                      try {
                        final imageId =
                            await ImageDownloader.downloadImage(url);
                        final path = await ImageDownloader.findPath(imageId!);
                        files.add(File(path!));
                      } catch (error) {
                        print(error);
                      }
                    }
                    setState(() {
                      _mulitpleFiles.addAll(files);
                    });
                  },
                  child: const Text("multiple downlod"),
                ),
                ElevatedButton(
                  onPressed: () => _downloadImage(
                    "https://raw.githubusercontent.com/wiki/ko2ic/image_downloader/images/sample.webp",
                    outputMimeType: "image/png",
                  ),
                  child: const Text("download webp(only Android)"),
                ),
                (_imageFile == null) ? Container() : Image.file(_imageFile!),
                GridView.count(
                  crossAxisCount: 4,
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  children: List.generate(_mulitpleFiles.length, (index) {
                    return SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.file(File(_mulitpleFiles[index].path)),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _downloadImage(
    String url, {
    AndroidDestinationType? destination,
    bool whenError = false,
    String? outputMimeType,
  }) async {
    if (await Permission.storage.request().isGranted) {
      String? fileName;
      String? path;
      int? size;
      String? mimeType;
      try {
        String? imageId;

        final apath = await _localPath;

        print(apath);

        print("zzzzzzzzzzzzz");

        var status = await Permission.storage.status;
        if (status.isGranted) {
          // We didn't ask for permission yet or the permission has been denied before but not permanently.
          print("存儲已授权");
        } else {
          print("存儲未333333333授权");
          // You can request multiple permissions at once.
          Map<Permission, PermissionStatus> statuses = await [
            Permission.location,
            Permission.storage,
          ].request();
          print(statuses[Permission.location]);
        }

        print("zzzzzzzzzzzzz----------------");

        if (whenError) {
          imageId = await ImageDownloader.downloadImage(url,
                  outputMimeType: outputMimeType)
              .catchError((error) {
            if (error is PlatformException) {
              String? path = "";
              if (error.code == "404") {
                print("Not Found Error.");
              } else if (error.code == "unsupported_file") {
                print("UnSupported FIle Error.");
                path = error.details["unsupported_file_path"];
              }
              setState(() {
                _message = error.toString();
                _path = path ?? '';
              });
            }

            print(error);
          }).timeout(const Duration(seconds: 10), onTimeout: () {
            print("timeout");
            return;
          });
        } else {
          if (destination == null) {
            imageId = await ImageDownloader.downloadImage(
              url,
              outputMimeType: outputMimeType,
            );
          } else {
            imageId = await ImageDownloader.downloadImage(
              url,
              destination: destination,
              outputMimeType: outputMimeType,
            );
          }
        }

        if (imageId == null) {
          return;
        }
        fileName = await ImageDownloader.findName(imageId);
        path = await ImageDownloader.findPath(imageId);
        size = await ImageDownloader.findByteSize(imageId);
        mimeType = await ImageDownloader.findMimeType(imageId);
      } on PlatformException catch (error) {
        setState(() {
          _message = error.message ?? '';
        });
        return;
      }

      if (!mounted) return;

      setState(() {
        var location = Platform.isAndroid ? "Directory" : "Photo Library";
        _message = 'Saved as "$fileName" in $location.\n';
        _size = 'size:     $size';
        _mimeType = 'mimeType: $mimeType';
        _path = path ?? '';

        if (!_mimeType.contains("video")) {
          _imageFile = File(path!);
        }
        return;
      });
    } else {
      print('nnnnnnnnnnnnnnnnnnnnnnnnn');
    }
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }
}
