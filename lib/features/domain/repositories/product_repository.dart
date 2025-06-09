import 'package:dartz/dartz.dart';
import 'package:abhi/core/error/failures.dart';
import 'package:abhi/features/domain/entities/product.dart';

abstract class ProductRepository {
  Future<Either<Failure, List<Product>>> getAllProducts();
}

