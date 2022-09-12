import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'widgets/holder.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [],
    );
    return MaterialApp(
      title: 'Abacus',
      theme: ThemeData.dark(),
      home: Container(
        color: Colors.black,
        child: Holder(),
      ),
    );
  }
}
