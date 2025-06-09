import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("게시판 화면"), centerTitle: true),
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
        child: Center(
          child: Container(height: double.infinity, width: 350, color: Colors.white,
          child: ListView(
            children: [
              Text("data"),
              Text("data"),
              Text("data"),
              Text("data"),
            ],
          ),),
        ),
      ),
    );
  }
}
