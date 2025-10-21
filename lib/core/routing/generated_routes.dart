// ______________ go router ______________

import 'package:clarity/core/routing/app_routes.dart';
import 'package:clarity/features/products/presentation/screens/product_details_screen.dart';
import 'package:clarity/features/products/presentation/screens/products_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RouteGenerator {
  static GoRouter mainRoutingInOurApp = GoRouter(
    errorBuilder: (context, state) =>
        const Scaffold(body: Center(child: Text('404 Not Found'))),
    initialLocation: AppRoutes.products,
    routes: [
      GoRoute(
        path: AppRoutes.products,
        name: AppRoutes.products,
        builder: (context, state) => const ProductsScreen(),
      ),
      GoRoute(
        path: '${AppRoutes.productsDetails}/:id',
        name: AppRoutes.productsDetails,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProductDetailsScreen(id: id);
        },
      ),
    ],
  );
}
