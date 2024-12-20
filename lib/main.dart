import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/queue_provider.dart';
import 'home_page.dart';

void main() {
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => QueueProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const MyHomePage(title: 'App Queue'),
      ),
    );
  }
}
