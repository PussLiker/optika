import 'package:flutter/material.dart';
import 'package:optika/pages/cart_screen.dart';
import 'package:optika/providers/cart_provider.dart';
import 'package:optika/services/api_service.dart';
import 'package:optika/models/product.dart';
import 'package:optika/services/api_config.dart';
import 'package:provider/provider.dart';

enum SortOption {
  brandAsc,
  brandDesc,
  priceAsc,
  priceDesc,
}

class CatalogScreen extends StatefulWidget {
  @override
  _CatalogScreenState createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final ApiService apiService = ApiService();
  late Future<List<Product>> _productsFuture;
  final ScrollController _scrollController = ScrollController();

  SortOption? _selectedSort = SortOption.priceAsc;

  @override
  void initState() {
    super.initState();
    _productsFuture = apiService.getProducts()
        .then((list) => list.where((p) => p.imageUrl != null && p.imageUrl!.isNotEmpty).toList());
  }

  List<Product> _sortedProducts(List<Product> items) {
    if (_selectedSort == null) return items;

    final sorted = List<Product>.from(items);
    switch (_selectedSort) {
      case SortOption.brandAsc:
        sorted.sort((a, b) => (a.brand?.name ?? '').compareTo(b.brand?.name ?? ''));
        break;
      case SortOption.brandDesc:
        sorted.sort((a, b) => (b.brand?.name ?? '').compareTo(a.brand?.name ?? ''));
        break;
      case SortOption.priceAsc:
        sorted.sort((a, b) => a.price.compareTo(b.price));
        break;
      case SortOption.priceDesc:
        sorted.sort((a, b) => b.price.compareTo(a.price));
        break;
      default:
        break;
    }
    return sorted;
  }
  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Каталог', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30)),
        backgroundColor: Color(0xFF045300),
        foregroundColor: Colors.white,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              // Логика открытия корзины
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CartScreen(
                    onClearCart: () {
                      setState(() {
                        Provider.of<CartProvider>(context, listen: false).clearCart();
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
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
                _buildCategorySection('Солнечные очки', products.where((p) => p.categoryId == 2).toList()),
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
        child: Icon(Icons.arrow_upward, color: Colors.white),
        backgroundColor: Color(0xFF274B24),
        mini: true,
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                DropdownButton<SortOption>(
                  value: _selectedSort,
                  underline: SizedBox(),
                  style: TextStyle(fontSize: 14, color: Colors.black),
                  items: [
                    DropdownMenuItem(
                      value: SortOption.brandAsc,
                      child: Text('Бренд ▲'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.brandDesc,
                      child: Text('Бренд ▼'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priceAsc,
                      child: Text('Цена ▲'),
                    ),
                    DropdownMenuItem(
                      value: SortOption.priceDesc,
                      child: Text('Цена ▼'),
                    ),
                  ],

                  onChanged: (SortOption? newValue) {
                    setState(() {
                      _selectedSort = newValue;
                    });
                  },
                ),
              ],
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
              childAspectRatio: 0.61,
            ),
            itemCount: _sortedProducts(items).length,
            itemBuilder: (context, index) => _buildProductCard(_sortedProducts(items)[index]),
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
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: product.imageUrl != null
                  ? Image.network(
                '${ApiConfig.baseUrl}${product.imageUrl}',
                height: 108,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, _, __) => Container(
                  height: 108,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                ),
              )
                  : Container(
                height: 108,
                width: double.infinity,
                color: Colors.grey[200],
                child: Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 1.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  product.brand?.name ?? 'Неизвестный бренд',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  product.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 4),
                Text(
                  '${product.price.toStringAsFixed(2)} руб',
                  style: TextStyle(color: Colors.grey[800], fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 5, 12, 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addToCart(product);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('${product.name} добавлен в корзину'), duration: Duration(milliseconds: 150)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF31A82A),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  'В корзину',
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
