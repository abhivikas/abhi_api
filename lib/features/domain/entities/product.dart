import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final int id;
  final String title;
  final String image;
  final double price;
  final String description;
  final String category;
  final Rating rating;

  const Product({
    required this.id,
    required this.title,
    required this.image,
    required this.price,
    required this.description,
    required this.category,
    required this.rating,
  });

  @override
  List<Object> get props => [id, title, image, price, description, category, rating];
}

class Rating extends Equatable {
  final double rate;
  final int count;

  const Rating({
    required this.rate,
    required this.count,
  });

  @override
  List<Object> get props => [rate, count];
}
