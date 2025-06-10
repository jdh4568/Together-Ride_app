import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PostWritePage extends StatefulWidget {
  const PostWritePage({super.key});

  @override
  State<PostWritePage> createState() => _PostWritePageState();
}

class _PostWritePageState extends State<PostWritePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController contentController = TextEditingController();

  Future<void> savePost() async {
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    final user = FirebaseAuth.instance.currentUser;
    final uid = user?.uid;

    if (title.isEmpty || content.isEmpty || uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("제목, 내용 모두 작성해주세요.")),
      );
      return;
    }

    // 🔥 Firestore에서 사용자 정보 불러오기
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();

    final userData = userDoc.data()!;
    final nickname = userData['nickname'] ?? '익명';
    final email = userData['email'] ?? '';

    // 🔥 게시글 저장 시 사용자 정보도 함께 저장
    await FirebaseFirestore.instance.collection('posts').add({
      'title': title,
      'content': content,
      'authorUid': uid,
      'authorNickname': nickname,
      'authorEmail': email,
      'createdAt': Timestamp.now(),
    });

    Navigator.pop(context);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF5F3F3),
      appBar: AppBar(title: const Text("글쓰기")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "제목"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: contentController,
              maxLines: 5,
              decoration: const InputDecoration(labelText: "내용"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: savePost,
              child: const Text("작성 완료"),
            ),
          ],
        ),
      ),
    );
  }
}
