import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login.dart';

class Register extends StatelessWidget {
  const Register({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController id = TextEditingController();
    final TextEditingController pw = TextEditingController();
    final TextEditingController pwCheck = TextEditingController();
    final TextEditingController nickName = TextEditingController();
    final TextEditingController age = TextEditingController();
    final TextEditingController gender = TextEditingController();

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

      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: id.text.trim(),
          password: pw.text.trim(),
        );
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

    return Scaffold(
      appBar: AppBar(title: const Text("회원가입 페이지"), centerTitle: true),
      body: SingleChildScrollView(
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
                      child: TextField(
                        controller: gender,
                        decoration: const InputDecoration(labelText: "성별"),
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
    );
  }
}
