import 'package:authentication_repository/authentication_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pantry_repository/pantry_repository.dart';
import 'package:the_pantry/home/home.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: HomeScreen());

  @override
  Widget build(BuildContext context) {
    final authRepository = context.read<AuthenticationRepository>();

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HomeCubit(),
        ),
        BlocProvider(
            create: (_) => PantryOverviewBloc(
                pantryRepository: context.read<PantryRepository>(),
                authRepository: authRepository)
              // ..add(PantryOverviewSubscriptionRequested(authRepository.currentUser))
              ..add(const PantryOverviewFilterChanged(
                  filter: PantryFilter.groceriesOnly())))
      ],
      child: const HomeView(),
    );
  }
}

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final selectedTab = context.select((HomeCubit cubit) => cubit.state.tab);

    return DefaultTabController(
      length: 2,
      child: Builder(builder: (context) {
        final TabController tabController = DefaultTabController.of(context)!;
        tabController.addListener(() {
          if (!tabController.indexIsChanging) {
            final index = tabController.index;
            context.read<HomeCubit>().setTab(index);
          }
        });
        return Scaffold(
          appBar: AppBar(
            backgroundColor: selectedTab == HomeTab.grocery
                ? Theme.of(context).primaryColor
                : Theme.of(context).secondaryHeaderColor,
            title: Text(
              selectedTab == HomeTab.grocery ? 'My Grocery List' : 'My Pantry',
            ),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.shopping_cart)),
                Tab(icon: Icon(Icons.home)),
              ],
            ),
          ),
          drawer: AppDrawer(
              color: selectedTab == HomeTab.grocery
                  ? Theme.of(context).primaryColorLight
                  : Theme.of(context).secondaryHeaderColor),
          body: const TabBarView(
            children: [
              PantryOverviewScreen(),
              PantryOverviewScreen(),
            ],
          ),
        );
      }),
    );
  }
}
