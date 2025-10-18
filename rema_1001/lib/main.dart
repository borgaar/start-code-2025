import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rema_1001/constants/theme.dart';
import 'package:rema_1001/data/api/api_client.dart';
import 'package:rema_1001/data/repositories/aisle_repository.dart';
import 'package:rema_1001/data/repositories/aisle_repository_impl.dart';
import 'package:rema_1001/data/repositories/llm_repository.dart';
import 'package:rema_1001/data/repositories/llm_repository_impl.dart';
import 'package:rema_1001/data/repositories/product_repository.dart';
import 'package:rema_1001/data/repositories/product_repository_impl.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository.dart';
import 'package:rema_1001/data/repositories/shopping_list_repository_impl.dart';
import 'package:rema_1001/data/repositories/store_repository.dart';
import 'package:rema_1001/data/repositories/store_repository_impl.dart';
import 'package:rema_1001/page/shopping_lists/cubit/shopping_lists_cubit.dart';
import 'package:rema_1001/router/router.dart';
import 'package:rema_1001/page/profile/settings/allergies/bloc/allergies_cubit.dart';
import 'package:rema_1001/page/profile/settings/cubit/settings_cubit.dart';
import 'package:skeletonizer/skeletonizer.dart';

Future<void> main() async {
  // Load environment variables from .env file
  await dotenv.load(fileName: ".env");
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
        RepositoryProvider<LlmRepository>(
          create: (context) => LlmRepositoryImpl(apiClient: apiClient),
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
