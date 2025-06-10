import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/post_detail.dart';
import 'post_write.dart'; // 글쓰기 페이지 import

class PostPage extends StatelessWidget {
  const PostPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("게시판 화면"), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PostWritePage()),
          );
        },
        child: const Icon(Icons.add),
      ),
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
            width: 350,
            color: Colors.white,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .orderBy('createdAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text("등록된 게시글이 없습니다."));
                }

                final posts = snapshot.data!.docs;

                return ListView.separated(
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index].data() as Map<String, dynamic>;
                    final title = post['title'] ?? '제목 없음';

                    return ListTile(
                      title: Text(title),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostDetailPage(
                                title: post['title'] ?? '',
                                content: post['content'] ?? '',
                                nickname: post['authorNickname'] ?? '익명',
                                email: post['authorEmail'] ?? '',
                                createdAt: (post['createdAt'] as Timestamp).toDate(),
                              ),
                            ),
                          );
                        }

                    );
                  },
                  separatorBuilder: (context, index) => const Divider(height: 1),
                );

              },
            ),
          ),
        ),
      ),
    );
  }
}
