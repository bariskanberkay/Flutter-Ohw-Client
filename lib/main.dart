
import 'package:flutter/material.dart';
import 'package:ohw_monitor/src/views/main_page.dart';
import 'package:provider/provider.dart';

import 'src/notifier/ohw_notifier.dart';

void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => OhwNotifier(),
    child: OhwApp(),
  ));
}

class OhwApp extends StatelessWidget {
  const OhwApp({super.key});

  @override
  Widget build(BuildContext context) {
    setContext(context);

    return MaterialApp(
      title: 'OHW Client',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainPage(),
    );
  }
}


