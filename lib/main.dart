import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_clean_arch/presentation/routes/app_router.dart';

void main() {
  FlutterError.onError = (details) {
    print("Flutter error : ${details.exception}");
  };
  runZonedGuarded(
    () {
      runApp(const MyApp());
    },
    (error, stacktrace) {
      print("Error : $error");
      print("StackTrace : $stacktrace");
    },
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AppRouter _router;
  late final AppRouterDelegate _routerDelegate;

  @override
  void initState() {
    super.initState();
    _router = AppRouter();
    _routerDelegate = AppRouterDelegate(_router);
  }

  @override
  void dispose() {
    _routerDelegate.dispose();
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppRouterScope(
      router: _router,
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        routerDelegate: _routerDelegate,
        routeInformationParser: AppRouteInformationParser(),
      ),
    );
  }
}
