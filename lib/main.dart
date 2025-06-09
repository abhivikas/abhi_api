import 'package:flutter/material.dart';
import 'package:abhi/features/presentation/pages/product_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'injection_container.dart' as di;
import 'package:abhi/features/presentation/bloc/product_bloc.dart';
import 'package:abhi/features/presentation/bloc/product_event.dart';
import 'package:abhi/features/presentation/bloc/product_state.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:abhi/features/presentation/bloc/search_bloc.dart';
import 'package:get_it/get_it.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await di.init();
    runApp(MyApp());
  } catch (e) {
    print('Error during initialization: $e');
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Text('Error initializing app: $e'),
        ),
      ),
    ));
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => di.sl<ProductBloc>()..add(LoadProducts()),
        ),
        BlocProvider(
          create: (context) => di.sl<SearchBloc>(),
        ),
      ],
      child: MaterialApp(
        title: 'Product App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.grey[100],
          appBarTheme: AppBarTheme(
            elevation: 0,
            centerTitle: true,
          ),
        ),
        home: BlocListener<ProductBloc, ProductState>(
          listener: (context, state) {
            if (state is ProductLoaded) {
              // Check if we're loading from cache
              final connectivityResult = context.read<Connectivity>().checkConnectivity();
              connectivityResult.then((result) {
                if (result == ConnectivityResult.none) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Showing offline data'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              });
            }
          },
          child: ProductPage(),
        ),
      ),
    );
  }
}
