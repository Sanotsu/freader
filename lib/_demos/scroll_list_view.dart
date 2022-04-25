// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    title: "ListView",
    debugShowCheckedModeBanner: false,
    home: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => MyState();
}

class MyState extends State {
  List<ItemEntity> entityList = [];
  final ScrollController _scrollController = ScrollController();
  bool isLoadData = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print("------------加载更多-------------");
        _getMoreData();
      }
    });
    for (int i = 0; i < 10; i++) {
      entityList.add(ItemEntity("Item  $i", Icons.accessibility));
    }
  }

  Future<void> _getMoreData() async {
    await Future.delayed(const Duration(seconds: 2), () {
      //模拟延时操作
      if (!isLoadData) {
        isLoadData = true;
        setState(() {
          isLoadData = false;
          List<ItemEntity> newList = List.generate(
              5,
              (index) => ItemEntity("上拉加载--item ${index + entityList.length}",
                  Icons.accessibility));
          entityList.addAll(newList);
        });
      }
    });
  }

  Future<void> _handleRefresh() async {
    print('-------开始刷新------------');
    await Future.delayed(const Duration(seconds: 2), () {
      //模拟延时
      setState(() {
        entityList.clear();
        entityList = List.generate(10,
            (index) => ItemEntity("下拉刷新后--item $index", Icons.accessibility));
        return;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("ListView"),
        ),
        body: RefreshIndicator(
            displacement: 50,
            color: Colors.redAccent,
            backgroundColor: Colors.blue,
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                if (index == entityList.length) {
                  return const LoadMoreView();
                } else {
                  return ItemView(entityList[index]);
                }
              },
              itemCount: entityList.length + 1,
              controller: _scrollController,
            ),
            onRefresh: _handleRefresh));
  }
}

/// 渲染Item的实体类
class ItemEntity {
  String title;
  IconData iconData;

  ItemEntity(this.title, this.iconData);
}

/// ListView builder生成的Item布局，读者可类比成原生Android的Adapter的角色
// ignore: must_be_immutable
class ItemView extends StatelessWidget {
  ItemEntity itemEntity;

  ItemView(this.itemEntity, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        height: 100,
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Text(
              itemEntity.title,
              style: const TextStyle(color: Colors.black87),
            ),
            Positioned(
                child: Icon(
                  itemEntity.iconData,
                  size: 30,
                  color: Colors.blue,
                ),
                left: 5)
          ],
        ));
  }
}

class LoadMoreView extends StatelessWidget {
  const LoadMoreView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Center(
          child: Row(
            children: const <Widget>[
              CircularProgressIndicator(),
              Padding(padding: EdgeInsets.all(10)),
              Text('加载中...')
            ],
            mainAxisAlignment: MainAxisAlignment.center,
          ),
        ),
      ),
      color: Colors.white70,
    );
  }
}
