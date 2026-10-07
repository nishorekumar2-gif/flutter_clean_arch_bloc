import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_arch/presentation/pages/dashboard_screen.dart';
import 'package:flutter_clean_arch/presentation/pages/home_screen.dart';
import 'package:flutter_clean_arch/presentation/pages/login_screen.dart';
import 'package:flutter_clean_arch/presentation/pages/profile_screen.dart';
import 'package:flutter_clean_arch/presentation/pages/splash_screen.dart';
import 'package:flutter_clean_arch/presentation/routes/app_routes.dart';
import 'package:flutter_clean_arch/presentation/viewmodels/home_screen_view_model.dart';
import 'package:flutter_clean_arch/presentation/viewmodels/login_view_model.dart';
import 'package:flutter_clean_arch/presentation/viewmodels/profile_view_model.dart';

class AppRouter extends ChangeNotifier {
  String _location = AppRoutes.splashScreen;

  String get location => _location;

  void goTo(String location) {
    _location = location;
    notifyListeners(); // Tells RouterDelegate to show the new page.
  }
}

class AppRouterScope extends InheritedNotifier<AppRouter> {
  const AppRouterScope({required AppRouter router, required super.child})
    : super(notifier: router);

  static AppRouter of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppRouterScope>();
    assert(scope != null, 'No AppRouterScope found in the widget tree');
    return scope!.notifier!;
  }
}

// Step 2: RouterDelegate turns the current URL into a page.
class AppRouterDelegate extends RouterDelegate<String>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<String> {
  AppRouterDelegate(this.router) {
    router.addListener(notifyListeners);
  }

  final AppRouter router;

  @override
  final navigatorKey = GlobalKey<NavigatorState>();

  @override
  String get currentConfiguration => router.location;

  // Called when the operating system gives the app a new deep-link URL.
  @override
  Future<void> setNewRoutePath(String location) async {
    router.goTo(location);
  }

  @override
  Widget build(BuildContext context) {
    final location = router.location;

    return Navigator(
      pages: [
        MaterialPage<void>(key: ValueKey(location), child: _pageFor(location)),
      ],
      onDidRemovePage: (_) => router.goTo(AppRoutes.splashScreen),
      key: ValueKey(location == AppRoutes.splashScreen ? 'splash' : location),
    );
  }

  Widget _pageFor(String location) {
    switch (location) {
      case AppRoutes.splashScreen:
        return const SplashScreen();
      case AppRoutes.loginPage:
        return BlocProvider(
          create: (_) => createLoginBloc(),
          child: const LoginPage(),
        );
      case AppRoutes.dashboard:
        return const DashboardScreen();
      case AppRoutes.profile:
      case '/dashboard/profile':
        return BlocProvider(
          create: (_) => createProfileViewModel(),
          child: const ProfileScreen(),
        );
      case AppRoutes.homeScreen:
        return BlocProvider(
          create: (_) => createHomeScreenViewModel(),
          child: const HomeScreen(),
        );
      default:
        return BlocProvider(
          create: (_) => createLoginBloc(),
          child: const LoginPage(),
        );
    }
  }

  @override
  void dispose() {
    router.removeListener(notifyListeners);
    super.dispose();
  }
}

// Step 1: Convert the incoming URL into the path used by the delegate.
class AppRouteInformationParser extends RouteInformationParser<String> {
  @override
  Future<String> parseRouteInformation(
    RouteInformation routeInformation,
  ) async {
    final path = routeInformation.uri.path;
    return path.isEmpty ? AppRoutes.splashScreen : path;
  }

  @override
  RouteInformation restoreRouteInformation(String location) {
    return RouteInformation(uri: Uri(path: location));
  }
}
