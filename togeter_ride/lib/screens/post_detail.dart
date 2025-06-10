import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 변환용
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../User.dart'; // UserModel, fetchUserData 정의된 경로로 변경

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;
  final String nickname;
  final String email;
  final DateTime createdAt;

  const PostDetailPage({
    super.key,
    required this.title,
    required this.content,
    required this.nickname,
    required this.email,
    required this.createdAt,
  });

  // 현재 사용자 정보 불러오기
  Future<bool> _checkInGroup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final user = await fetchUserData(uid);
    return user?.inGroup ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세보기")),
      // 버튼을 화면 하단 중앙에 띄우기 위해 지정
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<bool>(
        future: _checkInGroup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            // 로딩 중이거나 에러 시 버튼 숨김
            return const SizedBox.shrink();
          }
          final inGroup = snapshot.data ?? false;
          if (!inGroup) {
            // 가입되어 있지 않으면 버튼 표시
            return FloatingActionButton.extended(
              onPressed: () {
                // 가입 신청 로직을 여기에 구현하세요.
                // 예시: Firestore에 '가입 요청' 문서 추가 등
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("가입 신청 기능을 구현하세요.")),
                );
              },
              label: const Text("가입 신청하기"),
            );
          } else {
            return const SizedBox.shrink();
          }
        },
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            // 작성자 정보
            Text("작성자: $nickname ($email)",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("작성일: $formattedDate",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Divider(height: 32),

            // 내용
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
