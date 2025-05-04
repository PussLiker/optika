import 'package:flutter/material.dart';
import 'package:optika/models/auth/register_request.dart';
import 'package:optika/services/auth_service.dart';
import 'package:optika/pages/catalog_screen.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  String _name = '';
  String _lastName = '';
  bool _isLoading = false;

  final String adminPassword = "admin_password";

  String _getRole() {
    return _password == adminPassword ? 'admin' : 'user';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() => _isLoading = true);

    final success = await AuthService.register(RegisterRequest(
      name: _name,
      lastName: _lastName,
      email: _email,
      password: _password,
      role: _getRole(),
    ), );


    setState(() => _isLoading = false);

    if (success != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => CatalogScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка регистрации')),
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
            decoration: const InputDecoration(labelText: 'Имя'),
            validator: (val) =>
            val != null && val.isNotEmpty ? null : 'Введите имя',
            onSaved: (val) => _name = val!,
          ),
          TextFormField(
            decoration: const InputDecoration(labelText: 'Фамилия'),
            validator: (val) =>
            val != null && val.isNotEmpty ? null : 'Введите фамилию',
            onSaved: (val) => _lastName = val!,
          ),
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
            child: const Text('Зарегистрироваться'),
          ),
        ],
      ),
    );
  }
}

