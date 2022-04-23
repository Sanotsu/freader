import 'package:flutter/material.dart';

class ReadhubDaily extends StatelessWidget {
  final String? title;

  const ReadhubDaily({Key? key, this.title}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      // Create a grid with 2 columns. If you change the scrollDirection to
      // horizontal, this produces 2 rows.
      crossAxisCount: 2,
      // Generate 100 widgets that display their index in the List.
      children: List.generate(100, (index) {
        return Center(
          child: Text(
            // title ?? "" 如果title不为null，则显示，否则显示空字串
            '${title ?? ""} DAILY $index',
            style: Theme.of(context).textTheme.headline5,
          ),
        );
      }),
    );
  }
}
