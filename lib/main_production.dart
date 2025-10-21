import 'package:clarity/core/di/get_it.dart';
import 'package:clarity/core/routing/generated_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor:
          Colors.redAccent, // 👈 Make status bar transparent or set your color
      statusBarIconBrightness: Brightness.dark, // 👈 For Android
      statusBarBrightness: Brightness.light, // 👈 For iOS
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Cairo',
        primaryColor: const Color(0xff4BAA50),
      ),
      routerConfig: RouteGenerator.mainRoutingInOurApp,
    );
  }
}
