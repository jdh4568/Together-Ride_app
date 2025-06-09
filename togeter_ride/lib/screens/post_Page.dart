import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("게시판 화면"), centerTitle: true),
      body: Center(
        child: Container(height: double.infinity, width: 350, color: Colors.yellow,
        child: ListView(
          children: [
            Text("data"),
            Text("data"),
            Text("data"),
            Text("data"),
          ],
        ),),
      ),
    );
  }
}
