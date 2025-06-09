import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final TextEditingController id = TextEditingController();
  final TextEditingController pw = TextEditingController();
  final TextEditingController pwCheck = TextEditingController();
  final TextEditingController nickName = TextEditingController();
  final TextEditingController age = TextEditingController();

  int selectedGenderIndex = -1; // 0: 남자, 1: 여자
  final List<String> genderOptions = ["남자", "여자"];

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> register() async {
    if (id.text.isEmpty || pw.text.isEmpty || pwCheck.text.isEmpty) {
      showMessage("ID, PW는 필수 입력입니다.");
      return;
    }
    if (pw.text != pwCheck.text) {
      showMessage("비밀번호가 일치하지 않습니다.");
      return;
    }
    if (selectedGenderIndex == -1) {
      showMessage("성별을 선택해주세요.");
      return;
    }

    try {
      // 1. Firebase Auth로 회원가입
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: id.text.trim(),
        password: pw.text.trim(),
      );

      String uid = userCredential.user!.uid;

      // 2. Firestore에 추가 정보 저장
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': id.text.trim(),
        'nickname': nickName.text.trim(),
        'age': int.tryParse(age.text.trim()) ?? 0,
        'gender': genderOptions[selectedGenderIndex],
      });

      // 3. 완료 처리
      showMessage("회원가입 성공!");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    } on FirebaseAuthException catch (e) {
      showMessage("오류: ${e.message}");
    } catch (e) {
      showMessage("예상치 못한 오류 발생");
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("회원가입 페이지"), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xffB3E5FC),
              Color(0xff6BF8F3),
            ],
          ),
        ),

        child: SingleChildScrollView(
          child: Center(
            child: Container(
              margin: const EdgeInsets.only(top: 100),
              width: 300,
              padding: const EdgeInsets.all(16.0),
              color: Colors.blue[200],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 30),
                  const Text("회원 가입", style: TextStyle(fontSize: 24)),
                  const SizedBox(height: 20),
                  TextField(
                    controller: id,
                    decoration: const InputDecoration(labelText: "ID (이메일)"),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pw,
                    decoration: const InputDecoration(labelText: "PW"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: pwCheck,
                    decoration: const InputDecoration(labelText: "PW 확인"),
                    obscureText: true,
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: nickName,
                    decoration: const InputDecoration(labelText: "닉네임"),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: age,
                          decoration: const InputDecoration(labelText: "나이"),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("성별"),
                            const SizedBox(height: 4),
                            ToggleButtons(
                              isSelected: [
                                selectedGenderIndex == 0,
                                selectedGenderIndex == 1,
                              ],
                              onPressed: (index) {
                                setState(() {
                                  selectedGenderIndex = index;
                                });
                              },
                              children: const [
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("남자"),
                                ),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: Text("여자"),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  GestureDetector(
                    onTap: register,
                    child: Container(
                      width: 120,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(child: Text("회원 가입")),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
