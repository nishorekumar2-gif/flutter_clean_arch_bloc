import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_clean_arch/presentation/routes/app_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted && AppRouterScope.of(context).location == '/splash') {
        AppRouterScope.of(context).goTo('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) =>
      Scaffold(body: Center(child: Image.asset('assets/images/logo.png')));
}
