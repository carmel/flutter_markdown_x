import 'package:flutter/material.dart';
import 'screens/demo_screen.dart';
import 'screens/home_screen.dart';
import 'shared/markdown_demo_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Markdown Demos',
      initialRoute: '/',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
      onGenerateRoute: (RouteSettings settings) {
        return MaterialPageRoute<void>(
          builder: (_) => DemoScreen(
            child: settings.arguments as MarkdownDemoWidget?,
          ),
        );
      },
    );
  }
}
