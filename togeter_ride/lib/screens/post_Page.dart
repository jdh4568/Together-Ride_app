import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../user.dart'; // UserModel 클래스가 들어있는 파일 import

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  Future<UserModel?> loadUserInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return await fetchUserData(uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시판 화면"), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffB3E5FC), Color(0xff6BF8F3)],
          ),
        ),
        child: Center(
          child: Container(
            height: double.infinity,
            width: 350,
            color: Colors.white,
            child: FutureBuilder<UserModel?>(
              future: loadUserInfo(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("사용자 정보를 불러올 수 없습니다."));
                }

                final user = snapshot.data!;
                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Center(child: Text("게시판", style: TextStyle(fontSize: 20))),
                    const SizedBox(height: 20),
                    Text("닉네임: ${user.nickname}"),
                    Text("이메일: ${user.email}"),
                    Text("성별: ${user.gender}"),
                    Text("나이: ${user.age}"),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
