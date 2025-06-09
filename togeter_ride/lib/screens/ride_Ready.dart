import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RideReady extends StatelessWidget {
  const RideReady({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("라이딩 준비 화면"), centerTitle: true,),
      body: Center(child: Container(height: double.infinity, width: double.infinity, color: Colors.red,),),
    );
  }
}
