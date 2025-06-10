import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../User.dart';

class MyGroup extends StatelessWidget {
  const MyGroup({super.key});

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Future<QueryDocumentSnapshot<Map<String, dynamic>>?> _fetchMyGroupDoc() async {
    final uid = currentUid;
    if (uid == null) return null;
    final query = await FirebaseFirestore.instance
        .collection('groups')
        .where('members', arrayContains: uid)
        .limit(1)
        .get();
    if (query.docs.isEmpty) return null;
    return query.docs.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("내 그룹", style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffB3E5FC), Color(0xff6BF8F3)],
          ),
        ),
        child: FutureBuilder<QueryDocumentSnapshot<Map<String, dynamic>>?>(
          future: _fetchMyGroupDoc(),
          builder: (context, groupSnap) {
            if (groupSnap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!groupSnap.hasData || groupSnap.data == null) {
              return Center(
                child: Text(
                  "가입된 그룹이 없습니다.",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              );
            }
            final groupDoc = groupSnap.data!;
            final groupData = groupDoc.data();
            final groupName = (groupData['groupName'] as String?) ?? '이름 없음';
            final memberUids = List<String>.from(groupData['members'] ?? []);

            return Column(
              children: [
                const SizedBox(height: 20),
                Text(
                  "그룹명: $groupName",
                  style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xffF8F8F8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: memberUids.isEmpty
                        ? const Center(child: Text("그룹원이 없습니다."))
                        : ListView.separated(
                      itemCount: memberUids.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (context, index) {
                        final memberUid = memberUids[index];
                        return FutureBuilder<UserModel?>(
                          future: fetchUserData(memberUid),
                          builder: (context, userSnap) {
                            if (userSnap.connectionState ==
                                ConnectionState.waiting) {
                              return const ListTile(
                                title: Text("로딩 중..."),
                              );
                            }
                            if (!userSnap.hasData || userSnap.data == null) {
                              return ListTile(
                                title: const Text("알 수 없는 사용자"),
                                subtitle: Text(memberUid),
                              );
                            }
                            final user = userSnap.data!;
                            final isMe = memberUid == currentUid;
                            return ListTile(
                              leading: Icon(
                                  isMe ? Icons.person : Icons.person_outline),
                              title: Text(user.nickname),
                              subtitle: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text("나이: ${user.age}, 성별: ${user.gender}"),
                                  Text("이메일: ${user.email}"),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          },
        ),
      ),
    );
  }
}
