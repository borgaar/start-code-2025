import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rema_1001/constants/theme.dart';
import 'package:rema_1001/data/api/api_client.dart';
import 'package:rema_1001/data/repositories/aisle_repository.dart';
import 'package:rema_1001/data/repositories/aisle_repository_impl.dart';
import 'package:rema_1001/data/repositories/product_repository.dart';
import 'package:rema_1001/data/repositories/product_repository_impl.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository_impl.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/data/repositories/store_repository_impl.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_cubit.dart';
import 'package:rema_1001/router/router.dart';
import 'package:rema_1001/settings/allergies/bloc/allergies_cubit.dart';
import 'package:rema_1001/settings/cubit/settings_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API client
    final apiClient = ApiClient();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ProductRepository>(
          create: (context) => ProductRepositoryImpl(apiClient: apiClient),
        ),
        RepositoryProvider<ShoppingListRepository>(
          create: (context) => ShoppingListRepositoryImpl(apiClient: apiClient),
        ),
        RepositoryProvider<StoreRepository>(
          create: (context) => StoreRepositoryImpl(apiClient: apiClient),
        ),
        RepositoryProvider<AisleRepository>(
          create: (context) => AisleRepositoryImpl(apiClient: apiClient),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => SettingsCubit()),
          BlocProvider(create: (context) => AllergiesCubit()),
          BlocProvider(
            create: (context) => ShoppingListsCubit(
              repository: context.read<ShoppingListRepository>(),
            )..loadShoppingLists(emitLoading: true),
          ),
        ],
        child: SkeletonizerConfig(
          data: SkeletonizerConfigData.dark(
            enableSwitchAnimation: true,
            switchAnimationConfig: SwitchAnimationConfig(
              layoutBuilder: (currentChild, previousChildren) => Stack(
                children: [
                  ...previousChildren,
                  currentChild ?? SizedBox.shrink(),
                ],
              ),
            ),
          ),
          child: MaterialApp.router(
            debugShowCheckedModeBanner: false,
            title: 'Rema 1001',
            theme: themeData,
            routerConfig: router,
          ),
        ),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
