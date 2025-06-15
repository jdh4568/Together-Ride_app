import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/group_Page.dart';
import 'package:login/screens/post_Page.dart';
import 'package:login/screens/ride_Ready.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login/screens/my_group.dart';
import 'package:login/screens/riding.dart';
import '../User.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();
    _monitorAcceptedRide();
  }

  void _monitorAcceptedRide() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    FirebaseFirestore.instance
        .collectionGroup('participants')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: '수락')
        .snapshots()
        .listen((snapshot) async {
      for (var doc in snapshot.docs) {
        final rideDocRef = doc.reference.parent.parent;
        if (rideDocRef != null) {
          final rideSnapshot = await rideDocRef.get();
          if (rideSnapshot.exists && rideSnapshot.data()?['status'] != '종료') {
            if (mounted && ModalRoute.of(context)?.settings.name != '/riding') {
              Navigator.pushReplacementNamed(context, '/riding');
            }
          }
        }
      }
    });
  }

  Future<List<QueryDocumentSnapshot>> _fetchRideRequests() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final query = await FirebaseFirestore.instance
        .collectionGroup('participants')
        .where('uid', isEqualTo: uid)
        .where('status', isEqualTo: '응답 대기중')
        .get();

    return query.docs;
  }

  Future<UserModel?> _loadCurrentUser() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return await fetchUserData(uid);
  }

  void _onGroupManagePressed(BuildContext context) async {
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
    Navigator.pop(context);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("사용자 정보를 불러올 수 없습니다.")),
      );
      return;
    }

    if (user.inGroup) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MyGroup()),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => const GroupPage()),
      );
    }
  }

  void _respondToRequest(DocumentReference ref, String response) async {
    await ref.update({'status': response});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("메인 화면"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.logout),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (context.mounted) {
              Navigator.pushReplacementNamed(context, '/');
            }
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (context) {
                  return FutureBuilder<List<QueryDocumentSnapshot>>(
                    future: _fetchRideRequests(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        return const Center(child: Text("수신된 메시지가 없습니다."));
                      } else {
                        final rideRequests = snapshot.data!;
                        return ListView.builder(
                          itemCount: rideRequests.length,
                          itemBuilder: (context, index) {
                            final data = rideRequests[index].data() as Map<String, dynamic>;
                            final ref = rideRequests[index].reference;
                            final groupName = data['groupName'] ?? '그룹';
                            return ListTile(
                              title: Text("$groupName에서 라이딩 요청을 보냈습니다."),
                              subtitle: Row(
                                children: [
                                  TextButton(
                                    onPressed: () => _respondToRequest(ref, '거절'),
                                    child: const Text("거절"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => _respondToRequest(ref, '수락'),
                                    child: const Text("수락"),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      }
                    },
                  );
                },
              );
            },
          ),
        ],
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  final uid = FirebaseAuth.instance.currentUser?.uid;
                  if (uid == null) return;

                  final query = await FirebaseFirestore.instance
                      .collection('groups')
                      .where('members', arrayContains: uid)
                      .limit(1)
                      .get();

                  if (query.docs.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("가입된 그룹이 없습니다.")),
                    );
                    return;
                  }

                  final groupData = query.docs.first.data();
                  final leaderUid = groupData['leaderUid'] ?? '';

                  if (leaderUid == uid) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const RideReady()),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("그룹 리더만 라이딩 준비 페이지로 이동 가능합니다.")),
                    );
                  }
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xffF5F3F3),
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
