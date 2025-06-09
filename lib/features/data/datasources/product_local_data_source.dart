import 'package:hive/hive.dart';
import 'package:abhi/features/data/models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<ProductModel>> getCachedProducts();
  Future<void> cacheProducts(List<ProductModel> products);
  Future<void> clearCache();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<ProductModel> productBox;

  ProductLocalDataSourceImpl({required this.productBox});

  @override
  Future<List<ProductModel>> getCachedProducts() async {
    try {
      print('Getting cached products...');
      final cachedProducts = productBox.values.toList();
      print('Found ${cachedProducts.length} cached products');
      return cachedProducts;
    } catch (e) {
      print('Error getting cached products: $e');
      throw Exception('Failed to get cached products: $e');
    }
  }

  @override
  Future<void> cacheProducts(List<ProductModel> products) async {
    try {
      print('Caching ${products.length} products...');
      // Clear existing cache first
      await productBox.clear();
      
      // Add new products with unique keys
      for (var product in products) {
        await productBox.put(product.id, product);
      }
      print('Products cached successfully');
    } catch (e) {
      print('Error caching products: $e');
      throw Exception('Failed to cache products: $e');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      print('Clearing product cache...');
      await productBox.clear();
      print('Cache cleared successfully');
    } catch (e) {
      print('Error clearing cache: $e');
      throw Exception('Failed to clear cache: $e');
    }
  }
}
