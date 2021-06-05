import 'package:flutter/material.dart';

import 'home.page.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Worth Player Music',
      debugShowCheckedModeBanner: false,
      home: HomePage(title: 'Worth Player Music'),
    );
  }
}
