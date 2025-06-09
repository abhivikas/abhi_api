import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:abhi/features/domain/entities/product.dart';
import 'package:abhi/features/presentation/bloc/search_bloc.dart';

class SearchWidget extends StatelessWidget {
  final List<Product> products;
  final TextEditingController searchController;

  const SearchWidget({
    Key? key,
    required this.products,
    required this.searchController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchBloc, SearchState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search products...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        searchController.clear();
                        context.read<SearchBloc>().add(ClearSearch(products));
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onChanged: (query) {
              context.read<SearchBloc>().add(SearchQueryChanged(query, products));
            },
          ),
        );
      },
    );
  }
} 