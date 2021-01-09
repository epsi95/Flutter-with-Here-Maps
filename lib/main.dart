import 'package:flutter/material.dart';
import 'package:flutterwithheremaps/my_map.dart';
import 'package:here_sdk/core.dart';

void main() {
  SdkContext.init(IsolateOrigin.main);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Here Map Demo',
      home: SafeArea(
        child: Scaffold(
          body: MyFlutterMap(),
        ),
      ),
    );
  }
}
