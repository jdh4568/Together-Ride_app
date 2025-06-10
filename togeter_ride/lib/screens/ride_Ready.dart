import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:your_app/riding.dart'; // RidingPage 위젯 경로로 수정

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
  bool loading = true;
  bool selectAll = false;

  @override
  void initState() {
    super.initState();
    _loadGroupInfo();
  }

  Future<void> _loadGroupInfo() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        loading = false;
      });
      return;
    }
    try {
      // groups 컬렉션에서 members 배열에 현재 UID 포함된 문서 찾기
      final query = await FirebaseFirestore.instance
          .collection('groups')
          .where('members', arrayContains: uid)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        // 가입된 그룹 없음
        setState(() {
          loading = false;
          groupId = null;
          groupName = null;
          memberUids = [];
          selectedMembers = {};
        });
      } else {
        final doc = query.docs.first;
        final data = doc.data();
        final fetchedGroupName = data['groupName'] as String? ?? '이름 없음';
        final fetchedMemberUids = List<String>.from(data['members'] ?? []);
        // 초기 선택 맵: 모두 false
        final selMap = <String, bool>{};
        for (var m in fetchedMemberUids) {
          selMap[m] = false;
        }
        setState(() {
          groupId = doc.id;
          groupName = fetchedGroupName;
          memberUids = fetchedMemberUids;
          selectedMembers = selMap;
          loading = false;
          selectAll = false;
        });
      }
    } catch (e) {
      // 에러 시
      setState(() {
        loading = false;
        groupId = null;
        groupName = null;
        memberUids = [];
        selectedMembers = {};
      });
      // 원한다면 SnackBar로 알림
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("그룹 정보 불러오기 중 오류: $e")),
      );
    }
  }

  // 개별 멤버 닉네임 불러오기
  Future<String> _fetchNickname(String memberUid) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(memberUid)
          .get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        return (data['nickname'] as String?) ?? '이름 없음';
      }
    } catch (_) {}
    return '알 수 없음';
  }

  void _onSelectAllToggle() {
    final newSelectAll = !selectAll;
    final newMap = <String, bool>{};
    for (var uid in memberUids) {
      newMap[uid] = newSelectAll;
    }
    setState(() {
      selectAll = newSelectAll;
      selectedMembers = newMap;
    });
  }

  void _onMemberToggle(String uid) {
    final prev = selectedMembers[uid] ?? false;
    selectedMembers[uid] = !prev;
    // selectAll 상태 업데이트: 모든 값이 true면 true, 아니면 false
    final allSelected =
        selectedMembers.values.isNotEmpty && selectedMembers.values.every((v) => v);
    setState(() {
      selectAll = allSelected;
    });
  }

  void _onStartRide() {
    // 선택된 멤버 UIDs
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
    // TODO: 선택된 멤버와 함께 RidingPage로 이동. 예시:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (_) => RidingPage(
    //       groupId: groupId!,
    //       memberUids: chosen,
    //     ),
    //   ),
    // );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("선택 멤버: ${chosen.join(', ')}\n라이딩 시작!")),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Scaffold(
        appBar: AppBar(title: Text("라이딩 준비 화면"), centerTitle: true),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    // 그룹 정보가 없는 경우
    if (groupId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("라이딩 준비 화면"), centerTitle: true),
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
          child: Center(
            child: Text(
              "가입된 그룹이 없습니다.",
              style: TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ),
      );
    }
    // 그룹이 있는 경우, 그룹명과 멤버 리스트 보여주기
    return Scaffold(
      appBar: AppBar(title: const Text("라이딩 준비 화면"), centerTitle: true),
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
            // 그룹 이름
            Text(
              groupName ?? '',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 10),
            // 전체 선택 토글 버튼: 우측 상단에 위치시키려면 Row 사용
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
            // 그룹원 리스트
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
                    final isSelected = selectedMembers[memberUid] ?? false;
                    return FutureBuilder<String>(
                      future: _fetchNickname(memberUid),
                      builder: (context, snap) {
                        String titleText;
                        if (snap.connectionState == ConnectionState.waiting) {
                          titleText = "로딩 중...";
                        } else {
                          titleText = snap.data ?? '알 수 없음';
                        }
                        return CheckboxListTile(
                          value: isSelected,
                          onChanged: (_) => _onMemberToggle(memberUid),
                          title: Text(titleText),
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            // 라이딩 시작 버튼
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
