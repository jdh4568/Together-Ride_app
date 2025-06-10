import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'post_page.dart';      // PostPage import
import 'group_create.dart';  // GroupCreate import

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});
  void showGroupCreateDialog(BuildContext context) {
    final TextEditingController groupController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xffeeeeee),
          content: SizedBox(
            height: 180,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "그룹 생성",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: groupController,
                  decoration: InputDecoration(
                    hintText: "그룹 이름을 입력하세요.",
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    final groupName = groupController.text.trim();
                    if (groupName.isNotEmpty) {
                      Navigator.pop(context); // 팝업 닫기
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("그룹 '$groupName' 생성됨!")),
                      );
                      // Firestore에 그룹 저장 로직은 여기서 추가 가능
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[300],
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text("그룹 생성"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("그룹 관리 화면"), centerTitle: true),
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
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 100,
                width: 300,
                decoration: BoxDecoration(
                  color: const Color(0xffF5F3F3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    "가입된 그룹이 없습니다.\n그룹 가입 또는, 그룹 생성을 해주세요.",
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 100),

              // 👉 커뮤니티로 이동 버튼
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PostPage()),
                  );
                },
                child: Container(
                  height: 100,
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F3F3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(child: Text("커뮤니티로 이동")),
                ),
              ),

              const SizedBox(height: 50),

              // 👉 그룹 생성 버튼
              GestureDetector(
                onTap: () {
                  showGroupCreateDialog(context); // 팝업 띄우기
                },

                child: Container(
                  height: 100,
                  width: 200,
                  decoration: BoxDecoration(
                    color: const Color(0xffF5F3F3),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 2,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(child: Text("그룹 생성")),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
