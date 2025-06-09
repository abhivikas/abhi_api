import 'package:abhi/features/data/datasources/product_local_data_source.dart';
import 'package:abhi/features/data/datasources/product_remote_data_source.dart';
import 'package:abhi/features/data/repositories/product_repository_impl.dart';
import 'package:abhi/features/domain/repositories/product_repository.dart';
import 'package:abhi/features/domain/usecases/get_all_products.dart';
import 'package:abhi/features/presentation/bloc/product_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:abhi/features/data/models/product_model.dart';
import 'package:abhi/core/network/network_info.dart';
import 'package:abhi/features/presentation/bloc/search_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  if (!Hive.isAdapterRegistered(0)) {
    Hive.registerAdapter(ProductModelAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) {
    Hive.registerAdapter(RatingModelAdapter());
  }
  
  // Open boxes
  if (!Hive.isBoxOpen('productBox')) {
    await Hive.openBox<ProductModel>('productBox');
  }

  // External dependencies
  sl.registerLazySingleton(() => Dio());
  sl.registerLazySingleton(() => Connectivity());

  // Data sources
  sl.registerLazySingleton<ProductRemoteDataSource>(
    () => ProductRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<ProductLocalDataSource>(
    () => ProductLocalDataSourceImpl(productBox: Hive.box<ProductModel>('productBox')),
  );

  // Repositories
  sl.registerLazySingleton<ProductRepository>(() => ProductRepositoryImpl(
    remoteDataSource: sl(),
    localDataSource: sl(),
    networkInfo: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetAllProducts(sl()));

  // Bloc
  sl.registerFactory(() => ProductBloc(
    getAllProducts: sl(),
    networkInfo: sl(),
  ));
  sl.registerFactory(() => SearchBloc());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
}
