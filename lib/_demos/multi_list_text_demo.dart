import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late int textLength;
  static const textSize = 16.0;

  @override
  void initState() {
    textLength = Document.text.length;
    debugPrint('Text Length: $textLength');
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var deviceData = MediaQuery.of(context);
    var deviceHeight = deviceData.size.height;
    var deviceWidth =
        deviceData.size.width - 60; // 60 - AppBar estimated height
    var deviceDimension = deviceHeight * deviceWidth;

    /// Compute estimated character limit per page
    /// Estimated dimension of each character: textSize * (textSize * 0.8)
    /// textSize width estimated dimension is 80% of its height
    var pageCharLimit =
        (deviceDimension / (textSize * (textSize * 0.8))).round();
    debugPrint('Character limit per page: $pageCharLimit');

    /// Compute pageCount base from the computed pageCharLimit
    var pageCount = (textLength / pageCharLimit).round();
    debugPrint('Pages: $pageCount');

    List<String> pageText = [];
    var index = 0;
    var startStrIndex = 0;
    var endStrIndex = pageCharLimit;
    while (index < pageCount) {
      /// Update the last index to the Document Text length
      if (index == pageCount - 1) endStrIndex = textLength;

      /// Add String on List<String>
      pageText.add(Document.text.substring(startStrIndex, endStrIndex));

      /// Update index of Document Text String to be added on [pageText]
      if (index < pageCount) {
        startStrIndex = endStrIndex;
        endStrIndex += pageCharLimit;
      }
      index++;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: PageView.builder(
        itemCount: pageCount,
        itemBuilder: (_, index) {
          return Card(
            child: Container(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                pageText[index],
                style: const TextStyle(fontSize: textSize),
              ),
            ),
          );
        },
      ),

      // ListView.builder(
      //     itemCount: pageCount,
      //     itemBuilder: (BuildContext context, int index) {
      //       return Container(
      //         padding: const EdgeInsets.fromLTRB(0, 0, 0, 16.0),
      //         child: Card(
      //           child: Container(
      //             padding: const EdgeInsets.all(16.0),
      //             child: Text(
      //               pageText[index],
      //               style: const TextStyle(fontSize: textSize),
      //             ),
      //           ),
      //         ),
      //       );
      //     }),
    );
  }
}

class Document {
  static const text =
      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Nunc sed velit dignissim sodales ut eu sem. Enim nec dui nunc mattis enim ut tellus elementum sagittis. Augue lacus viverra vitae congue eu. Posuere morbi leo urna molestie at elementum eu. Sed faucibus turpis in eu mi bibendum neque egestas congue. Id volutpat lacus laoreet non curabitur gravida arcu. Ut tristique et egestas quis ipsum suspendisse ultrices gravida. Sit amet mattis vulputate enim nulla. Risus pretium quam vulputate dignissim suspendisse in. Vel pharetra vel turpis nunc eget lorem dolor sed. Ac turpis egestas maecenas pharetra convallis posuere morbi. Quam nulla porttitor massa id neque aliquam vestibulum. Ut tortor pretium viverra suspendisse potenti nullam ac tortor. Quam lacus suspendisse faucibus interdum posuere lorem ipsum. Posuere lorem ipsum dolor sit amet. Imperdiet nulla malesuada pellentesque elit eget gravida cum sociis.'
      '\n\nQuam elementum pulvinar etiam non quam lacus suspendisse faucibus. Congue quisque egestas diam in arcu cursus euismod quis. Felis donec et odio pellentesque diam volutpat. Maecenas accumsan lacus vel facilisis volutpat est velit egestas. Leo urna molestie at elementum. Facilisi nullam vehicula ipsum a arcu cursus vitae congue mauris. At imperdiet dui accumsan sit. Porttitor lacus luctus accumsan tortor posuere. Volutpat odio facilisis mauris sit amet massa vitae. Ut eu sem integer vitae justo eget magna fermentum iaculis. Volutpat diam ut venenatis tellus in metus vulputate eu scelerisque. Morbi enim nunc faucibus a pellentesque sit amet porttitor eget. Sed odio morbi quis commodo.'
      '\n\nEu mi bibendum neque egestas congue quisque egestas. Libero id faucibus nisl tincidunt. Nunc mi ipsum faucibus vitae aliquet nec ullamcorper. Tristique nulla aliquet enim tortor. Risus nec feugiat in fermentum posuere. Eu non diam phasellus vestibulum. Sit amet venenatis urna cursus. Amet venenatis urna cursus eget nunc scelerisque viverra mauris in. A arcu cursus vitae congue mauris rhoncus aenean. Maecenas sed enim ut sem viverra aliquet eget. Scelerisque purus semper eget duis at tellus at. Aliquam malesuada bibendum arcu vitae. Sed augue lacus viverra vitae congue eu. Sit amet est placerat in egestas erat imperdiet sed euismod. Venenatis tellus in metus vulputate eu scelerisque felis imperdiet proin. Volutpat consequat mauris nunc congue. Nec dui nunc mattis enim ut tellus elementum. Amet purus gravida quis blandit turpis cursus. Nisl suscipit adipiscing bibendum est ultricies integer quis auctor elit.'
      '\n\nNunc vel risus commodo viverra maecenas accumsan. Felis donec et odio pellentesque diam volutpat commodo. Sodales ut etiam sit amet nisl purus in mollis. Et netus et malesuada fames ac. Pretium aenean pharetra magna ac placerat vestibulum lectus mauris. Pulvinar pellentesque habitant morbi tristique. Nisl purus in mollis nunc sed id semper risus in. Elit ut aliquam purus sit amet luctus venenatis. Nulla aliquet enim tortor at. Amet luctus venenatis lectus magna fringilla urna porttitor rhoncus. Aliquam malesuada bibendum arcu vitae. Urna nec tincidunt praesent semper feugiat nibh. Vestibulum mattis ullamcorper velit sed ullamcorper morbi tincidunt ornare. Vel turpis nunc eget lorem dolor sed viverra. Bibendum neque egestas congue quisque egestas. Leo a diam sollicitudin tempor id eu. Consectetur lorem donec massa sapien. Consequat ac felis donec et odio. Sed velit dignissim sodales ut eu sem integer vitae justo.'
      '\n\nInteger vitae justo eget magna fermentum iaculis. Lorem ipsum dolor sit amet consectetur adipiscing elit ut. Id porta nibh venenatis cras sed felis eget velit aliquet. Non sodales neque sodales ut etiam. Nunc faucibus a pellentesque sit amet porttitor. Ultricies tristique nulla aliquet enim tortor. Cursus metus aliquam eleifend mi. Arcu non odio euismod lacinia at quis. Sed lectus vestibulum mattis ullamcorper velit sed. Tortor aliquam nulla facilisi cras. Quam vulputate dignissim suspendisse in est ante in nibh mauris. Pretium nibh ipsum consequat nisl vel pretium lectus. Eget lorem dolor sed viverra. Neque ornare aenean euismod elementum nisi quis eleifend.'
      '\n\nDiam vel quam elementum pulvinar etiam non quam lacus suspendisse. Dui vivamus arcu felis bibendum ut tristique et. Gravida neque convallis a cras semper. Nisl nunc mi ipsum faucibus vitae aliquet. Vitae justo eget magna fermentum. Odio morbi quis commodo odio aenean sed adipiscing. Est ullamcorper eget nulla facilisi etiam dignissim. Dictum sit amet justo donec enim diam vulputate ut pharetra. Consequat id porta nibh venenatis cras sed felis eget. Ut porttitor leo a diam. Ipsum dolor sit amet consectetur adipiscing elit duis tristique sollicitudin. Vulputate enim nulla aliquet porttitor lacus luctus accumsan tortor posuere. Sit amet consectetur adipiscing elit duis tristique sollicitudin nibh sit. Phasellus faucibus scelerisque eleifend donec.'
      '\n\nAc feugiat sed lectus vestibulum mattis ullamcorper velit. Placerat duis ultricies lacus sed turpis tincidunt. Faucibus a pellentesque sit amet. Sagittis vitae et leo duis ut diam. Augue interdum velit euismod in pellentesque massa. At urna condimentum mattis pellentesque. Potenti nullam ac tortor vitae purus. Cursus mattis molestie a iaculis at erat pellentesque adipiscing. Tortor consequat id porta nibh venenatis cras. Sagittis nisl rhoncus mattis rhoncus urna. Elit eget gravida cum sociis natoque penatibus et. Vitae et leo duis ut diam quam. Eu turpis egestas pretium aenean pharetra. Morbi tincidunt ornare massa eget egestas purus. Eget nulla facilisi etiam dignissim diam quis enim lobortis scelerisque.'
      '\n\nFaucibus ornare suspendisse sed nisi lacus sed viverra tellus. Dignissim diam quis enim lobortis scelerisque fermentum. Turpis tincidunt id aliquet risus. Quam adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus urna. Dolor magna eget est lorem ipsum dolor. Nam aliquam sem et tortor consequat id porta nibh venenatis. At augue eget arcu dictum varius duis at consectetur. Felis eget velit aliquet sagittis id. At elementum eu facilisis sed odio. Habitant morbi tristique senectus et netus et malesuada fames ac. Vitae congue eu consequat ac felis donec et odio. Ipsum dolor sit amet consectetur adipiscing elit ut aliquam purus. Non arcu risus quis varius quam quisque id diam. Rhoncus urna neque viverra justo nec ultrices dui sapien eget. Accumsan in nisl nisi scelerisque eu ultrices vitae auctor.'
      '\n\nSed adipiscing diam donec adipiscing tristique risus. Massa vitae tortor condimentum lacinia quis vel eros. Non enim praesent elementum facilisis leo vel fringilla est ullamcorper. Rhoncus dolor purus non enim praesent elementum. Praesent semper feugiat nibh sed pulvinar proin. Nisl condimentum id venenatis a condimentum vitae sapien pellentesque habitant. Sit amet dictum sit amet justo donec enim diam. Consectetur adipiscing elit pellentesque habitant morbi tristique senectus. Et netus et malesuada fames ac turpis. Viverra aliquet eget sit amet tellus cras adipiscing enim. Tristique senectus et netus et. Sed lectus vestibulum mattis ullamcorper velit sed.'
      '\n\nIaculis urna id volutpat lacus. Imperdiet massa tincidunt nunc pulvinar sapien et. Posuere sollicitudin aliquam ultrices sagittis orci a. Eu volutpat odio facilisis mauris sit amet. Scelerisque eleifend donec pretium vulputate sapien nec sagittis aliquam. Sit amet nisl purus in mollis nunc sed id. Maecenas accumsan lacus vel facilisis volutpat est velit. Tortor at risus viverra adipiscing at in tellus. Arcu ac tortor dignissim convallis. Nisi scelerisque eu ultrices vitae auctor eu augue ut lectus. Consectetur adipiscing elit pellentesque habitant morbi tristique senectus. Quis lectus nulla at volutpat. Diam in arcu cursus euismod quis viverra nibh cras pulvinar. Libero id faucibus nisl tincidunt eget. Tellus in hac habitasse platea dictumst vestibulum rhoncus est pellentesque. Odio morbi quis commodo odio aenean sed. Vitae suscipit tellus mauris a diam maecenas. Non pulvinar neque laoreet suspendisse interdum consectetur. Libero nunc consequat interdum varius sit amet. Tincidunt id aliquet risus feugiat in ante.';
}
