import 'package:flutter/material.dart';
import 'pages/home_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Optika App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CatalogScreen(), // Здесь ты указываешь главный экран приложения
    );
  }
}

