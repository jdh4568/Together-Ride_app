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
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle, // ← 원형으로 지정 (borderRadius보다 더 정확)
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.6), // 더 자연스러운 그림자 느낌
                          spreadRadius: 8,
                          blurRadius: 20,
                          offset: Offset(0, 5),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.grey.shade300, // 바깥쪽 테두리 느낌용
                        width: 2,
                      ),
                    ),
                    child: Container(
                      margin: const EdgeInsets.all(10), // 내부 원 효과
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xffF5F3F3),
                      ),
                      alignment: Alignment.center,
                      child: const Text(
                        "라이딩 준비",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  )

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
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xffF5F3F3),
                  ),
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
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xffF5F3F3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: Offset(0, 1), // changes position of shadow
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: const Text("커뮤니티"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
