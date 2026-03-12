import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const GleisGuruApp());
}

class GleisGuruApp extends StatelessWidget {
  const GleisGuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gleis-Guru',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}