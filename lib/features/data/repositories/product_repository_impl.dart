import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';

import '../../domain/entities/product.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_local_data_source.dart';
import '../datasources/product_remote_data_source.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/product_model.dart';
import 'package:abhi/core/error/failures.dart';
import 'package:abhi/core/error/exceptions.dart';
import 'package:abhi/core/network/network_info.dart';

@LazySingleton(as: ProductRepository)
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;
  final ProductLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  ProductRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, List<Product>>> getAllProducts() async {
    try {
      if (await networkInfo.isConnected) {
        print('Internet available, fetching from API...');
        final remoteProducts = await remoteDataSource.fetchProducts();
        
        // Cache the products after successful API fetch
        await localDataSource.cacheProducts(remoteProducts);
        print('Products cached successfully');
        
        return Right(remoteProducts);
      } else {
        print('No internet connection, loading from cache...');
        final cachedProducts = await localDataSource.getCachedProducts();
        if (cachedProducts.isEmpty) {
          return Left(CacheFailure('No cached data available'));
        }
        return Right(cachedProducts);
      }
    } catch (e) {
      print('Error in repository: $e');
      if (await networkInfo.isConnected) {
        return Left(ServerFailure());
      } else {
        return Left(CacheFailure());
      }
    }
  }
}
