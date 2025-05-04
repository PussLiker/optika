import 'package:flutter/material.dart';
import 'package:optika/pages/forms/login_form.dart';
import 'package:optika/pages/forms/register_form.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLogin = true;

  void _toggleForm() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Авторизация'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Expanded(
              child: _isLogin
                  ? LoginForm(onToggleForm: _toggleForm)
                  : RegisterForm(onToggleForm: _toggleForm),
            ),

          ],
        ),
      ),
    );
  }
}