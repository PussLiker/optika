import 'package:flutter/material.dart';
import 'package:optika/models/auth/login_request.dart';
import 'package:optika/services/auth_service.dart';
import 'package:optika/pages/catalog_screen.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final success = await AuthService.login(LoginRequest(
      email: _email,
      password: _password,
    ));

    setState(() => _isLoading = false);

    if (success != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CatalogScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка входа')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (val) =>
            val != null && val.contains('@') ? null : 'Неверный email',
            onSaved: (val) => _email = val!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Пароль'),
            obscureText: true,
            validator: (val) =>
            val != null && val.length >= 6 ? null : 'Мин. 6 символов',
            onSaved: (val) => _password = val!,
          ),
          const SizedBox(height: 20),
          _isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
            onPressed: _submit,
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }
}
