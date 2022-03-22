import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:the_pantry/constants.dart';
import 'package:the_pantry/home/home.dart';
import 'package:the_pantry/pantry_overview/pantry_overview.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(child: HomeScreen());

  @override
  Widget build(BuildContext context) {
    return BlocProvider<HomeCubit>(
      create: (_) => HomeCubit(),
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: selectedTab == HomeTab.grocery
              ? AppTheme.blue
              : AppTheme.redBrown,
          title: Text(
            selectedTab == HomeTab.grocery ? 'My Grocery List' : 'My Pantry',
            style: const TextStyle(
                color: Colors.white,
                fontSize: 18.0,
                fontWeight: FontWeight.bold),
          ),
          bottom: TabBar(
            indicatorColor: AppTheme.paleYellow,
            tabs: const [
              Tab(icon: Icon(Icons.shopping_cart)),
              Tab(icon: Icon(Icons.home)),
            ],
            onTap: (int index) {
              context.read<HomeCubit>().setTab(index);
            },
          ),
        ),
        drawer: AppDrawer(
            color: selectedTab == HomeTab.grocery
                ? AppTheme.blue
                : AppTheme.redBrown),
        body: const TabBarView(
          children: [
            GroceryScreen(color: AppTheme.blue),
            GroceryScreen(color: AppTheme.redBrown),
          ],
        ),
      ),
      length: 2,
    );
  }
}
