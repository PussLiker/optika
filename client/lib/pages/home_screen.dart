import 'package:flutter/material.dart';
import 'package:optika/services/api_service.dart';
import 'package:optika/models/product.dart';
import 'package:optika/models/brand.dart';

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> _productsFuture;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _productsFuture = apiService.getProducts()
        .then((list) =>
        list.where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty).toList()
    );
  }

  void _scrollToTop() {
    _scrollController.jumpTo(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Каталог', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        centerTitle: false, // Центрируем заголовок

      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return Center(child: CircularProgressIndicator());
          if (snapshot.hasError)
            return Center(child: Text('Ошибка загрузки товаров'));

          final products = snapshot.data!;
          if (products.isEmpty)
            return Center(child: Text('Нет доступных товаров'));

          return SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCategorySection('Оправы', products.where((p) => p.categoryId == 1).toList()),
                Divider(),
                _buildCategorySection('Солнцезащитные очки', products.where((p) => p.categoryId == 2).toList()),
                Divider(),
                _buildCategorySection('Линзы', products.where((p) => p.categoryId == 3).toList()),
                Divider(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _scrollToTop,
        child: Icon(Icons.arrow_upward, color: Colors.black),
        backgroundColor: Colors.green,
      ),
    );
  }

  Widget _buildCategorySection(String title, List<Product> items) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 8),
          GridView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.61, // Увеличение плиток
            ),
            itemCount: items.length,
            itemBuilder: (context, index) => _buildProductCard(items[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(Product product) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      child: Column(
        children: [
          // Изображение с отступами
          Padding(
            padding: const EdgeInsets.all(12.0), // Увеличены отступы
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                'http://192.168.0.42:5197${product.imageUrl}',
                height: 108,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(
                  height: 180,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              ),
            ),
          ),
          // Текстовая информация
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 5.0), // Равные отступы
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Центрирование текста
              children: [
                Text(
                  product.brand!.name,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.1),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14, height: 1.1),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(2)} руб',
                  style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, height: 1.1),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          // Кнопка с равными отступами
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: EdgeInsets.symmetric(vertical: 4, horizontal: 0), // Высота кнопки увеличена
                ),
                child: Text(
                  'Добавить\nв корзину',
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
