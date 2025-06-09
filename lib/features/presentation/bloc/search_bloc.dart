import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abhi/features/domain/entities/product.dart';
import 'dart:async';

// Events
abstract class SearchEvent {}

class SearchQueryChanged extends SearchEvent {
  final String query;
  final List<Product> products;

  SearchQueryChanged(this.query, this.products);
}

class ClearSearch extends SearchEvent {
  final List<Product> products;
  
  ClearSearch(this.products);
}

// States
abstract class SearchState {}

class SearchInitial extends SearchState {}

class SearchLoading extends SearchState {}

class SearchLoaded extends SearchState {
  final List<Product> products;
  final String query;

  SearchLoaded(this.products, {this.query = ''});
}

class SearchError extends SearchState {
  final String message;

  SearchError(this.message);
}

// Bloc
class SearchBloc extends Bloc<SearchEvent, SearchState> {
  Timer? _debounce;

  SearchBloc() : super(SearchInitial()) {
    on<SearchQueryChanged>(_onSearchQueryChanged);
    on<ClearSearch>(_onClearSearch);
  }

  void _onSearchQueryChanged(SearchQueryChanged event, Emitter<SearchState> emit) async {
    print('Search event received with query: ${event.query}'); // Debug print
    print('Total products to search: ${event.products.length}'); // Debug print

    // Emit loading state immediately
    emit(SearchLoading());

    if (event.query.isEmpty) {
      print('Empty query, showing all products'); // Debug print
      emit(SearchLoaded(event.products, query: ''));
      return;
    }

    // Cancel previous timer if it exists
    _debounce?.cancel();

    // Set a new timer
    _debounce = Timer(const Duration(milliseconds: 300), () {
      final query = event.query.toLowerCase();
      print('Searching for: $query'); // Debug print

      final filteredProducts = event.products.where((product) {
        final title = product.title.toLowerCase();
        final price = product.price.toString();
        final matches = title.contains(query) || price.contains(query);
        if (matches) {
          print('Found match: ${product.title}'); // Debug print
        }
        return matches;
      }).toList();

      print('Found ${filteredProducts.length} matches'); // Debug print

      if (filteredProducts.isEmpty) {
        print('No matches found'); // Debug print
        emit(SearchError('No products found matching "$query"'));
      } else {
        print('Emitting ${filteredProducts.length} products'); // Debug print
        emit(SearchLoaded(filteredProducts, query: event.query));
      }
    });
  }

  void _onClearSearch(ClearSearch event, Emitter<SearchState> emit) {
    print('Clearing search'); // Debug print
    _debounce?.cancel();
    emit(SearchLoaded(event.products, query: ''));
  }

  @override
  Future<void> close() {
    _debounce?.cancel();
    return super.close();
  }
} 