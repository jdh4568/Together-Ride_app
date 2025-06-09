import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/group_Page.dart';
import 'package:login/screens/post_Page.dart';
import 'package:login/screens/ride_Ready.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text("메인 화면"), centerTitle: true),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 라이딩 페이지 이동 버튼
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const RideReady()),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text("라이딩 준비"),
              ),
            ),
            const SizedBox(height: 30),

            // 그룹 관리 페이지 이동 버튼
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const GroupPage()),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text("그룹 관리"),
              ),
            ),
            const SizedBox(height: 50),

            // 커뮤니티 게시판 이동 버튼
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PostPage()),
                );
              },
              child: Container(
                width: 100,
                height: 100,
                color: Colors.grey,
                alignment: Alignment.center,
                child: const Text("커뮤니티"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
