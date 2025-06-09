import 'package:flutter/material.dart';
import 'package:abhi/features/domain/entities/product.dart';
import 'package:abhi/features/presentation/widgets/product_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:abhi/features/presentation/widgets/product_details_bottom_sheet.dart';

class FavoritesPage extends StatefulWidget {
  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late Box<Product> _favoritesBox;
  List<Product> _favorites = [];

  @override
  void initState() {
    super.initState();
    _initFavorites();
  }

  Future<void> _initFavorites() async {
    _favoritesBox = await Hive.openBox<Product>('favorites');
    setState(() {
      _favorites = _favoritesBox.values.toList();
    });
    print('FavoritesPage: Favorites initialized. Count: ${_favorites.length}');
  }

  void _toggleFavorite(Product product) {
    setState(() {
      if (_favorites.contains(product)) {
        _favorites.remove(product);
        _favoritesBox.delete(product.id);
        print('FavoritesPage: Removed favorite: ${product.id}. Favorites count: ${_favorites.length}');
      } else {
        _favorites.add(product);
        _favoritesBox.put(product.id, product);
        print('FavoritesPage: Added favorite: ${product.id}. Favorites count: ${_favorites.length}');
      }
    });
  }

  bool _isFavorite(Product product) {
    final isFav = _favorites.contains(product);
    print('FavoritesPage: Checking favorite for ${product.id}: $isFav. Favorites: ${_favorites.map((e) => e.id).toList()}');
    return isFav;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        
        title: Text(
          'Favourites',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _favorites.isEmpty ? _buildEmptyState() : _buildFavoritesList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.favorite_border,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No favorites added yet',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add products to your favorites by tapping the heart icon',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesList() {
    return ListView.builder(
      padding: EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final product = _favorites[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => ProductDetailsBottomSheet(
                  product: product,
                  isFavorite: _isFavorite(product),
                  onFavoriteToggle: () => _toggleFavorite(product),
                ),
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.image_not_supported,
                            color: Colors.grey[400],
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                              valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Product Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  children: [
    // Price
    Text(
      '\$${product.price.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.deepPurple,
      ),
    ),

    // Rating in the center
    Row(
      children: [
        const Icon(
          Icons.star,
          size: 16,
          color: Colors.amber,
        ),
        const SizedBox(width: 4),
        Text(
          product.rating.rate.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    ),

    // Favorite Icon
    IconButton(
      icon: Icon(
        _isFavorite(product)
            ? Icons.favorite
            : Icons.favorite_border,
        color: _isFavorite(product) ? Colors.red : Colors.grey,
      ),
      onPressed: () => _toggleFavorite(product),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
      iconSize: 24,
    ),
  ],
),


                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
