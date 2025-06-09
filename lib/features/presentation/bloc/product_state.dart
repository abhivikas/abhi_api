import 'package:equatable/equatable.dart';
import 'package:abhi/features/domain/entities/product.dart';

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object> get props => [];
}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<Product> products;
  final bool isOffline;

  const ProductLoaded({
    required this.products,
    this.isOffline = false,
  });

  @override
  List<Object> get props => [products, isOffline];
}

class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object> get props => [message];
}
