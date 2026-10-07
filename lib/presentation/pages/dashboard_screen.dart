import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_arch/data/datasources/dio_client.dart';
import 'package:flutter_clean_arch/presentation/pages/home_screen.dart';
import 'package:flutter_clean_arch/presentation/pages/profile_screen.dart';
import 'package:flutter_clean_arch/presentation/viewmodels/home_screen_view_model.dart';
import 'package:flutter_clean_arch/presentation/viewmodels/profile_view_model.dart';

class DashboardCubit extends Cubit<int> {
  DashboardCubit() : super(0);

  void selectTab(int index) => emit(index);
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => DashboardCubit(),
    child: const _DashboardContent(),
  );
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent();

  @override
  Widget build(BuildContext context) => BlocBuilder<DashboardCubit, int>(
    builder: (context, selectedIndex) {
      final pages = [
        BlocProvider(
          create: (_) => createHomeScreenViewModel(),
          child: const HomeScreen(),
        ),
        BlocProvider(
          create: (_) => createProfileViewModel(),
          child: const ProfileScreen(),
        ),
        const SizedBox.shrink(),
      ];

      return Scaffold(
        body: pages[selectedIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: context.read<DashboardCubit>().selectTab,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
              icon: Icon(Icons.verified_user),
              label: "Profile",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: "Settings",
            ),
          ],
        ),
      );
    },
  );
}

Future<ProductDetails> getProductList() async {
  final response = await dioClient.get(
    "https://dummyjson.com/products",
    options: Options(headers: {"content-type": "application/json"}),
  );
  //print("Response : $response");
  return response as ProductDetails;
}

Future<ProductDetails> addProduct(
  int userId,
  int productId,
  int quantity,
) async {
  final product = {"id": productId, "quantity": quantity};

  final productList = [];
  productList.add(product);

  final response = await dioClient.post(
    "https://dummyjson.com/carts/add",
    options: Options(
      headers: {"content-type": "applicaton/json"},
      extra: {"userId": userId, "products": productList},
    ),
  );
  return response as ProductDetails;
}

class ProductDetails {
  int? userId;
  int? productId;
  int? quantity;
}
