import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:optika/providers/cart_provider.dart';
import 'package:optika/pages/catalog_screen.dart';
import 'package:provider/provider.dart';


void main() async {
  // 1. Инициализируем биндинги
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Настраиваем полноэкранный режим
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.immersiveSticky,
    overlays: [SystemUiOverlay.top], // Оставить статус-бар (опционально)
  );

  // 3. Запускаем приложение
  runApp(
    // Оборачиваем всё приложение в ChangeNotifierProvider
    ChangeNotifierProvider(
      create: (_) => CartProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => CartProvider(), // Провайдер создается на уровне приложения
      child: MaterialApp(
        title: 'Моя Оптика',
        theme: ThemeData(
          fontFamily: 'Roboto',
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: CatalogScreen(),  // Главный экран
      ),
    );
  }
}
