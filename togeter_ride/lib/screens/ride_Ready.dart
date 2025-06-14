import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../ride.dart';


class RideReady extends StatefulWidget {
  const RideReady({super.key});

  @override
  State<RideReady> createState() => _RideReadyState();
}

class _RideReadyState extends State<RideReady> {
  String? groupId;
  String? groupName;
  List<String> memberUids = [];
  Map<String, bool> selectedMembers = {};
  Map<String, String> memberStatuses = {};
  bool loading = true;
  bool selectAll = false;
  String rideId = '';
  String? currentUid;

  @override
  void initState() {
    super.initState();
    currentUid = FirebaseAuth.instance.currentUser?.uid;
    _loadGroupInfo();
  }

  Future<void> _loadGroupInfo() async {
    currentUid ??= FirebaseAuth.instance.currentUser?.uid;
    if (currentUid == null) {
      setState(() => loading = false);
      return;
    }

    try {
      // 🔍 그룹 정보 로딩
      final query = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: currentUid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        setState(() => loading = false);
        return;
      }

      final doc = query.docs.first;
      final data = doc.data();
      final fetchedGroupName = data['groupName'] as String? ?? '이름 없음';
      final fetchedMemberUids = List<String>.from(data['members'] ?? []);
      final selMap = <String, bool>{};
      final statusMap = <String, String>{};
      for (var m in fetchedMemberUids) {
        selMap[m] = false;
        statusMap[m] = "요청 전";
      }

      // ✅ rideId 처리
      final rideQuery = await FirebaseFirestore.instance
          .collection('ride_requests')
          .where('leaderUid', isEqualTo: currentUid)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (rideQuery.docs.isNotEmpty) {
        final latestDoc = rideQuery.docs.first;
        final data = latestDoc.data();
        final status = data.containsKey('status') ? data['status'] : '';

        if (status == '종료') {
          // 새 라이딩 시작 준비
          rideId = DateTime.now().millisecondsSinceEpoch.toString();
        } else {
          // 기존 라이딩 진행 중
          rideId = latestDoc.id;
          _listenToResponses(); // 기존 요청에 대한 응답 감시 시작
        }
      } else {
        rideId = DateTime.now().millisecondsSinceEpoch.toString();
      }

      setState(() {
        groupId = doc.id;
        groupName = fetchedGroupName;
        memberUids = fetchedMemberUids;
        selectedMembers = selMap;
        memberStatuses = statusMap;
        loading = false;
      });
    } catch (e) {
      print("🔥 _loadGroupInfo 오류: $e");
      setState(() => loading = false);
    }
  }


  Future<String> _fetchNickname(String memberUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberUid)
          .get();
      if (doc.exists && doc.data() != null) {
        return (doc.data()!['nickname'] as String?) ?? '이름 없음';
      }
    } catch (_) {}
    return '알 수 없음';
  }

  void _onSelectAllToggle() {
    final newSelectAll = !selectAll;
    final newMap = <String, bool>{};
    for (var uid in memberUids) {
      if (uid != currentUid) newMap[uid] = newSelectAll;
    }
    setState(() {
      selectAll = newSelectAll;
      selectedMembers = newMap;
    });
  }

  void _onMemberToggle(String uid) {
    final prev = selectedMembers[uid] ?? false;
    selectedMembers[uid] = !prev;
    final allSelected = selectedMembers.values.isNotEmpty &&
        selectedMembers.values.every((v) => v);
    setState(() {
      selectAll = allSelected;
    });
  }

  Future<void> _onStartRide() async {
    final chosen = selectedMembers.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();
    if (chosen.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("최소 한 명 이상의 멤버를 선택해주세요.")),
      );
      return;
    }

    await FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(rideId)
        .set({
      'leaderUid': currentUid,
      'groupId': groupId,
      'createdAt': FieldValue.serverTimestamp(),
      'status': '대기중', // ✅ 필수 필드 추가
    });


    for (String uid in chosen) {
      await FirebaseFirestore.instance
          .collection('ride_requests')
          .doc(rideId)
          .collection('participants')
          .doc(uid)
          .set({
        'uid': uid,
        'groupName': groupName,
        'displayName': await _fetchNickname(uid),
        'status': '응답 대기중',
        'requestedAt': FieldValue.serverTimestamp(),
      });
      setState(() {
        memberStatuses[uid] = '응답 대기중';
      });
    }

    _listenToResponses();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("${chosen.length}명에게 라이딩 요청 전송 완료")),
    );
  }

  void _listenToResponses() {
    FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(rideId)
        .collection('participants')
        .snapshots()
        .listen((snapshot) {
      bool allResponded = true;
      int acceptedCount = 0;

      for (var doc in snapshot.docs) {
        final uid = doc.id;
        final data = doc.data();
        if (data.containsKey('status')) {
          final status = data['status'];
          if (status == '응답 대기중') {
            allResponded = false;
          } else if (status == '수락') {
            acceptedCount++;
          }
          setState(() {
            memberStatuses[uid] = status;
          });
        }
      }

      // ✅ 모든 사람이 응답 완료 && 수락자 1명 이상이면 이동
      if (allResponded && acceptedCount > 0) {
        // 리더 포함한 인원이기 때문에 여기에 조건이 맞으면 이동
        Future.delayed(const Duration(milliseconds: 500), () {
          Navigator.pushReplacementNamed(context, '/riding');
        });
      }
    });
  }


  Color _statusColor(String status) {
    switch (status) {
      case "응답 대기중":
        return Colors.orange;
      case "수락":
        return Colors.green;
      case "거절":
        return Colors.red;
      case "그룹 리더":
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: const Text("라이딩 준비 화면")),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("라이딩 준비 화면")),
        body: const Center(child: Text("가입된 그룹이 없습니다.")),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text("라이딩 준비 화면")),
      body: Container(
        padding: const EdgeInsets.only(top: 10.0),
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xffB3E5FC), Color(0xff6BF8F3)],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              groupName ?? '',
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  const Spacer(),
                  TextButton(
                    onPressed: _onSelectAllToggle,
                    child: Text(selectAll ? "전체 해제" : "전체 선택"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 5),
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xffF8F8F8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListView.separated(
                  itemCount: memberUids.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final memberUid = memberUids[index];
                    final isLeader = memberUid == currentUid;
                    final isSelected = selectedMembers[memberUid] ?? false;
                    final status = isLeader ? "그룹 리더" : (memberStatuses[memberUid] ?? "요청 전");

                    return FutureBuilder<String>(
                      future: _fetchNickname(memberUid),
                      builder: (context, snap) {
                        final name = snap.connectionState == ConnectionState.waiting
                            ? "로딩 중..."
                            : snap.data ?? "알 수 없음";

                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: isLeader
                                  ? ListTile(
                                leading: const Icon(Icons.person, color: Colors.grey),
                                title: Text(name),
                                trailing: Text(
                                  status,
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              )
                                  : CheckboxListTile(
                                value: isSelected,
                                onChanged: (_) => _onMemberToggle(memberUid),
                                title: Text(name),
                                controlAffinity: ListTileControlAffinity.leading,
                                secondary: Text(
                                  status,
                                  style: TextStyle(
                                    color: _statusColor(status),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _onStartRide,
              child: Container(
                height: 50,
                width: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
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
                child: const Text("라이딩 시작"),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}