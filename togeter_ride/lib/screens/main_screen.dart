import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/group_Page.dart';
import 'package:login/screens/post_Page.dart';
import 'package:login/screens/ride_Ready.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/my_group.dart';

import '../User.dart'; // MyGroupPage 정의된 곳

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  Future<UserModel?> _loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return await fetchUserData(uid);
  }

  void _onGroupManagePressed(BuildContext context) async {
    // 로딩 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    UserModel? user;
    try {
      user = await _loadCurrentUser();
    } catch (e) {
      user = null;
    }
    Navigator.pop(context); // 로딩 닫기

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용자 정보를 불러올 수 없습니다.")),
      );
      return;
    }

    if (user.inGroup) {
      // 이미 그룹에 가입된 경우: MyGroupPage로 이동
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MyGroup()),
      );
    } else {
      // 그룹 미가입 상태: GroupPage로 이동
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GroupPage()),
      );
    }
  }

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
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.6),
                        spreadRadius: 8,
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: Colors.grey.shade300,
                      width: 2,
                    ),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(10),
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
                ),
              ),
              const SizedBox(height: 30),

              // 그룹 관리 페이지 이동 버튼 (inGroup에 따라 분기)
              GestureDetector(
                onTap: () => _onGroupManagePressed(context),
                child: Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 1),
                      ),
                    ],
                    borderRadius: BorderRadius.circular(10),
                    color: const Color(0xffF5F3F3),
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
                    color: const Color(0xffF5F3F3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 1,
                        offset: const Offset(0, 1),
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
