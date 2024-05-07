






import 'package:face/features/train_face/presentation/views/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';




void main()  {


  WidgetsFlutterBinding.ensureInitialized(); // Ensure that Flutter is initialized

  runApp(
    const ProviderScope(
      child:  MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {

  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}


class _MyAppState extends State<MyApp> {



// background colour  hex #3a3b45
  //button hex  #0cdec1 and #0ad8e6

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3a3b45)),
        useMaterial3: true,
      ),
      home: SafeArea(child: HomeScreen()),
    );
  }
}







