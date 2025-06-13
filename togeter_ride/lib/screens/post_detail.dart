import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../User.dart';

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

  Future<bool> _checkInGroup() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final user = await fetchUserData(uid);
    return user?.inGroup ?? false;
  }

  Future<void> _sendJoinRequest(BuildContext context) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) return;
    final currentUser = await fetchUserData(currentUid);
    if (currentUser == null) return;

    // 그룹장 UID 찾기 (email 기준)
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: email)
        .limit(1)
        .get();

    if (query.docs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("그룹장을 찾을 수 없습니다.")),
      );
      return;
    }

    final leaderDoc = query.docs.first;
    final leaderUid = leaderDoc.id;

    // 그룹장 하위 join_requests 서브컬렉션에 문서 추가
    await FirebaseFirestore.instance
        .collection('join_requests')
        .doc(leaderUid)
        .collection('messages')
        .add({
      'uid': currentUid,
      'nickname': currentUser.nickname,
      'gender': currentUser.gender,
      'age': currentUser.age,
      'point': currentUser.point,
      'requestedAt': FieldValue.serverTimestamp(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("가입 신청이 전송되었습니다.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세보기")),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FutureBuilder<bool>(
        future: _checkInGroup(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox.shrink();
          }
          final inGroup = snapshot.data ?? false;
          if (!inGroup) {
            return FloatingActionButton.extended(
              onPressed: () => _sendJoinRequest(context),
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
                style:
                const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text("작성자: $nickname ($email)",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            Text("작성일: $formattedDate",
                style: const TextStyle(fontSize: 14, color: Colors.grey)),
            const Divider(height: 32),
            Text(content, style: const TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}