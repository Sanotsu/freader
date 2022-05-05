import 'package:flutter/material.dart';

/// 悬浮在app上的widget(更好理解)
/// https://stackoverflow.com/questions/57069641/how-to-overlay-a-widget-on-top-of-a-flutter-app
///
void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Offset _offset = Offset.zero;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const LoginPage(),
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            Positioned(
              left: _offset.dx,
              top: _offset.dy,
              child: GestureDetector(
                onPanUpdate: (d) =>
                    setState(() => _offset += Offset(d.delta.dx, d.delta.dy)),
                child: FloatingActionButton(
                  onPressed: () {
                    // ignore: avoid_print
                    print("xxxxxxxxxxx");
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class LoginPage extends StatelessWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LoginPage')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const HomePage()),
          ),
          child: const Text('Page2'),
        ),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('HomePage')),
      body: const FlutterLogo(size: 300),
    );
  }
}
