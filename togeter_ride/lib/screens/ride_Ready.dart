import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideReady extends StatelessWidget {
  const RideReady({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("라이딩 준비 화면"), centerTitle: true,),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffB3E5FC),
              Color(0xff6BF8F3),
            ],
          ),
        ),
      )
    );
  }
}
