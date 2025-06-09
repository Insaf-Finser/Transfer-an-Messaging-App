// ignore_for_file: depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:transfer/presentaion/SplashPage/splashpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:transfer/presentaion/menu/menu.dart';
import 'firebase_options.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      home: const MenuPage(),
    );
  }
}