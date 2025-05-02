import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optika/pages/auth_screen.dart';
import 'package:optika/pages/catalog_screen.dart';
import 'package:optika/providers/cart_provider.dart';
import 'package:optika/services/auth_service.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top],
  );

  final isLoggedIn = await AuthService.isAuthenticated();

  runApp(
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MyApp(isLoggedIn: isLoggedIn),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Моя Оптика',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: isLoggedIn ? CatalogScreen() : AuthPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
