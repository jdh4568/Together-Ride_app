import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // 날짜 형식 변환용

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

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd HH:mm').format(createdAt);

    return Scaffold(
      appBar: AppBar(title: const Text("게시글 상세보기")),
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
