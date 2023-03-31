// ignore_for_file: avoid_print, deprecated_member_use

import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WillPopScope(
        onWillPop: () async => !await _navigatorKey.currentState!.maybePop(),
        child: LayoutBuilder(
          builder: (context, constraints) {
            WidgetsBinding.instance
                .addPostFrameCallback((_) => _insertOverlay(context));
            return Navigator(
              key: _navigatorKey,
              onGenerateRoute: (RouteSettings settings) {
                switch (settings.name) {
                  case '/page2':
                    return MaterialPageRoute(builder: (_) => const Page2());
                  default:
                    return MaterialPageRoute(
                        builder: (_) => Page1(_navigatorKey));
                }
              },
            );
          },
        ),
      ),
    );
  }

  void _insertOverlay(BuildContext context) {
    return Overlay.of(context).insert(
      OverlayEntry(builder: (context) {
        final size = MediaQuery.of(context).size;
        print(size.width);
        return Positioned(
          width: 56,
          height: 56,
          top: size.height - 72,
          left: size.width - 72,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: () => print('ON TAP OVERLAY!'),
              child: Container(
                decoration: const BoxDecoration(
                    shape: BoxShape.circle, color: Colors.redAccent),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class Page1 extends StatelessWidget {
  final GlobalKey<NavigatorState> navigatorKey;

  const Page1(this.navigatorKey, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[200],
      appBar: AppBar(title: const Text('Page1')),
      body: Container(
        alignment: Alignment.center,
        child: ElevatedButton(
          child: const Text('go to Page2'),
          onPressed: () => navigatorKey.currentState!.pushNamed('/page2'),
        ),
      ),
    );
  }
}

class Page2 extends StatelessWidget {
  const Page2({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.yellow[200],
      appBar: AppBar(title: const Text('back to Page1')),
      body: Container(
        alignment: Alignment.center,
        child: const Text('Page 2'),
      ),
    );
  }
}
