import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pos/authen/authen_bloc.dart';
import 'package:pos/repository/mqtt/client.dart';
import 'package:pos/repository/order/order_repoository.dart';
import 'package:pos/repository/category/category_repository.dart';
import 'package:pos/repository/localized/locale_constant.dart';
import 'package:pos/repository/menu/menu_repository.dart';
import 'package:pos/repository/theme/theme_repository.dart';
import 'app_view.dart';
import './repository/repository.dart';

class App extends StatelessWidget {
  const App({
    super.key,
    required this.authenticationRepository,
    required this.userRepository,
  });

  final AuthenticationRepository authenticationRepository;
  final UserRepository userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ThemeRepository>(
          create: (context) => ThemeRepository(context: context),
        ),
        RepositoryProvider<AuthenticationRepository>(
          create: (context) => authenticationRepository,
        ),
        RepositoryProvider<LocalRepository>(
          create: (context) => LocalRepository(),
        ),
        RepositoryProvider<MenuRepository>(
          create: (context) => MenuRepository(),
        ),
        RepositoryProvider<CategoryRepository>(
          create: (context) => CategoryRepository(),
        ),
        RepositoryProvider<OrderRepoository>(
          create: (context) => OrderRepoository(),
        ),
        RepositoryProvider<OrderRepoository>(
          create: (context) => OrderRepoository(),
        ),
        RepositoryProvider<DisplayClient>(
          create: (context) => DisplayClient(config: BrokerConfig()),
        ),
      ],
      child: BlocProvider(
        create: (_) => AuthenticationBloc(
          authenticationRepository: authenticationRepository,
          userRepository: userRepository,
        ),
        child: const AppView(),
      ),
    );
  }
}
