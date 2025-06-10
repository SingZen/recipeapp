import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:recipeapp/core/services/recipe_service.dart';
import 'view/pages/home/home_page.dart';
import 'view/pages/login/login_page.dart';
import 'view/pages/splash/splash_page.dart';
import 'viewmodel/auth_viewmodel.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await RecipeService.initRecipes();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AuthViewModel(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Recipe App',
      theme: ThemeData(primarySwatch: Colors.teal),
      debugShowCheckedModeBanner: false,
      home: Consumer<AuthViewModel>(
        builder: (context, authVM, _) {
          if (authVM.isLoading) return SplashPage();
          if (authVM.user != null) return HomePage();
          return LoginPage();
        },
      ),
    );
  }
}
