import 'package:flutter/material.dart';
import 'package:test_app/src/pages/chatPage.dart';
import 'package:test_app/src/rust/frb_generated.dart';

Future<void> main() async {
  await RustLib.init();
  runApp(const MyApp());
}


class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return  const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Chat()
    );
  }

}

