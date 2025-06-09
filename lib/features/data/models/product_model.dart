import 'package:hive/hive.dart';
import 'package:abhi/features/domain/entities/product.dart';
import 'package:json_annotation/json_annotation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

part 'product_model.g.dart';

@HiveType(typeId: 0)
class ProductModel extends Product {
  @HiveField(0)
  final int id;
  
  @HiveField(1)
  final String title;
  
  @HiveField(2)
  final String image;
  
  @HiveField(3)
  final double price;

  @HiveField(4)
  final String? cachedImageData;

  @HiveField(5)
  final String description;

  @HiveField(6)
  final String category;

  @HiveField(7)
  final RatingModel rating;

  const ProductModel({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
    required this.rating,
    this.cachedImageData,
  }) : super(
          id: id,
          title: title,
          image: image,
          price: price,
          description: description,
          category: category,
          rating: rating,
        );

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    try {
      return ProductModel(
        id: json['id'] as int,
        title: json['title'] as String? ?? '',
        image: json['image'] as String? ?? '',
        price: (json['price'] is int)
            ? (json['price'] as int).toDouble()
            : json['price'] as double,
        description: json['description'] as String? ?? '',
        category: json['category'] as String? ?? '',
        rating: RatingModel.fromJson(json['rating'] as Map<String, dynamic>),
      );
    } catch (e) {
      print('Error parsing product: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'image': image,
        'price': price,
        'description': description,
        'category': category,
        'rating': rating.toJson(),
        'cachedImageData': cachedImageData,
      };

  Future<void> cacheImage() async {
    if (cachedImageData == null) {
      try {
        final response = await http.get(Uri.parse(image));
        if (response.statusCode == 200) {
          final newModel = ProductModel(
            id: id,
            title: title,
            image: image,
            price: price,
            description: description,
            category: category,
            rating: rating,
            cachedImageData: base64Encode(response.bodyBytes),
          );
          // Update the cached data in Hive
          final box = Hive.box<ProductModel>('productBox');
          await box.put(id, newModel);
        }
      } catch (e) {
        print('Error caching image: $e');
      }
    }
  }

  String? getCachedImageData() => cachedImageData;
}

@HiveType(typeId: 1)
class RatingModel extends Rating {
  @HiveField(0)
  final double rate;

  @HiveField(1)
  final int count;

  const RatingModel({
    required this.rate,
    required this.count,
  }) : super(
          rate: rate,
          count: count,
        );

  factory RatingModel.fromJson(Map<String, dynamic> json) {
    return RatingModel(
      rate: (json['rate'] as num).toDouble(),
      count: json['count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'rate': rate,
        'count': count,
      };
}