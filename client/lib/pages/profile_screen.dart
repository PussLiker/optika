import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Профиль', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF800020),
        foregroundColor: Colors.white,
      ),
      body: Center(child: Text('Добро пожаловать!')),
    );
  }
}
