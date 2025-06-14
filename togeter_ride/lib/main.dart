import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login/screens/login.dart';
import 'package:login/screens/riding.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});


  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Login(), routes: {
      '/riding': (context) => const Riding(), // 실제 라이딩 화면 위젯
    },theme: ThemeData(scaffoldBackgroundColor: Color(0xffF5F3F3),),);
  }
}
