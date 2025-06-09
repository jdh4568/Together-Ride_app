import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("그룹 관리 화면"),centerTitle: true,),
      body: Center(child: Container(height: double.infinity, width: double.infinity, color: Colors.red,),),
    );
  }
}
