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
      child: MyApp(initialRoute: isLoggedIn ? '/catalog' : '/auth'),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

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
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/auth': (context) => const AuthPage(),
        '/catalog': (context) => CatalogScreen()
      }
    );
  }
}
