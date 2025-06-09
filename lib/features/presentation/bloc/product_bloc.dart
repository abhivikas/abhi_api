import 'package:abhi/features/domain/usecases/get_products.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abhi/features/domain/entities/product.dart';
import 'product_event.dart';
import 'product_state.dart';
import 'package:abhi/features/domain/usecases/get_all_products.dart';
import 'package:abhi/core/error/failures.dart';
import 'package:abhi/core/network/network_info.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final GetAllProducts getAllProducts;
  final NetworkInfo networkInfo;
  List<Product> _allProducts = [];

  ProductBloc({
    required this.getAllProducts,
    required this.networkInfo,
  }) : super(ProductInitial()) {
    on<LoadProducts>(_onLoadProducts);
    on<SearchProducts>(_onSearchProducts);
  }

  Future<void> _onLoadProducts(LoadProducts event, Emitter<ProductState> emit) async {
    emit(ProductLoading());

    try {
      final isConnected = await networkInfo.isConnected;
      if (!isConnected) {
        print('No internet connection, loading from cache...');
        if (_allProducts.isNotEmpty) {
          emit(ProductLoaded(
            products: _allProducts,
            isOffline: true,
          ));
          return;
        }
      }

      final result = await getAllProducts();
      
      result.fold(
        (failure) {
          print('Error loading products: ${failure.message}');
          if (_allProducts.isNotEmpty) {
            emit(ProductLoaded(
              products: _allProducts,
              isOffline: true,
            ));
          } else {
            emit(ProductError(failure.message ?? 'Failed to load products'));
          }
        },
        (products) {
          print('Successfully loaded ${products.length} products');
          _allProducts = products;
          emit(ProductLoaded(
            products: _allProducts,
            isOffline: !isConnected,
          ));
        },
      );
    } catch (e) {
      print('Unexpected error: $e');
      if (_allProducts.isNotEmpty) {
        emit(ProductLoaded(
          products: _allProducts,
          isOffline: true,
        ));
      } else {
        emit(ProductError('An unexpected error occurred'));
      }
    }
  }

  Future<void> _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(ProductLoaded(
        products: _allProducts,
        isOffline: false,
      ));
      return;
    }

    emit(ProductLoading());
    try {
      if (_allProducts.isEmpty) {
        final result = await getAllProducts();
        result.fold(
          (failure) => emit(ProductError(failure.toString())),
          (products) {
            _allProducts = products;
            final filteredProducts = products
                .where((p) => p.title.toLowerCase().contains(event.query.toLowerCase()))
                .toList();
            emit(ProductLoaded(
              products: filteredProducts,
              isOffline: false,
            ));
          },
        );
      } else {
        final filteredProducts = _allProducts
            .where((p) => p.title.toLowerCase().contains(event.query.toLowerCase()))
            .toList();
        emit(ProductLoaded(
          products: filteredProducts,
          isOffline: false,
        ));
      }
    } catch (e) {
      emit(ProductError('Failed to search products: $e'));
    }
  }
}