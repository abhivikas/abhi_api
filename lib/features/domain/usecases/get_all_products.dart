import 'package:dartz/dartz.dart';
import 'package:abhi/core/error/failures.dart';
import 'package:abhi/features/domain/entities/product.dart';
import 'package:abhi/features/domain/repositories/product_repository.dart';

class GetAllProducts {
  final ProductRepository repository;

  GetAllProducts(this.repository);

  Future<Either<Failure, List<Product>>> call() async {
    return await repository.getAllProducts();
  }
} 