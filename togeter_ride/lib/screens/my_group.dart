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

  void _showJoinRequests(BuildContext context, String leaderUid) {
    showModalBottomSheet(
      context: context,
      builder: (_) => StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('join_requests')
            .doc(leaderUid)
            .collection('messages')
            .orderBy('requestedAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Padding(
              padding: EdgeInsets.all(20),
              child: Text("가입 요청이 없습니다."),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            separatorBuilder: (_, __) => const Divider(),
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data();
              final nickname = data['nickname'] ?? '이름 없음';
              final gender = data['gender'] ?? '-';
              final age = data['age']?.toString() ?? '-';
              final point = data['point']?.toString() ?? '0';
              final requestUid = data['uid'] as String?;

              return ListTile(
                title: Text("$nickname ($gender, $age세) - $point포인트"),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () async {
                        if (requestUid == null) return;
                        final groupDoc = await _fetchMyGroupDoc();
                        if (groupDoc == null) return;
                        final groupRef = groupDoc.reference;

                        await groupRef.update({
                          'members': FieldValue.arrayUnion([requestUid]),
                        });

                        await FirebaseFirestore.instance
                            .collection('users')
                            .doc(requestUid)
                            .update({
                          'inGroup': true,
                        });

                        await doc.reference.delete();
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () async {
                        await doc.reference.delete();
                      },
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
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
            final leaderUid = groupData['leaderUid'] as String?;
            final isLeader = leaderUid == currentUid;

            return Stack(
              children: [
                Column(
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
                                if (!userSnap.hasData ||
                                    userSnap.data == null) {
                                  return ListTile(
                                    title: const Text("알 수 없는 사용자"),
                                    subtitle: Text(memberUid),
                                  );
                                }
                                final user = userSnap.data!;
                                final isMe = memberUid == currentUid;
                                final isLeaderMember = memberUid == leaderUid;
                                return ListTile(
                                  leading: Icon(
                                    isLeaderMember
                                        ? Icons.person
                                        : isMe
                                        ? Icons.person
                                        : Icons.person_outline,
                                  ),
                                  title: Text(user.nickname),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          "나이: ${user.age}, 성별: ${user.gender}, 포인트 : ${user.point}P"),
                                      Text("이메일: ${user.email}"),
                                      if (isLeaderMember)
                                        const Text("그룹 리더",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight:
                                                FontWeight.bold))
                                    ],
                                  ),
                                  enabled: !isLeaderMember,
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
                if (isLeader && leaderUid != null)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: FloatingActionButton(
                      onPressed: () => _showJoinRequests(context, leaderUid),
                      child: const Icon(Icons.mail),
                      tooltip: "가입 요청 확인",
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
