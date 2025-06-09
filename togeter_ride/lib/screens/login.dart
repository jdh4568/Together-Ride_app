import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:login/screens/main_screen.dart';
import 'package:login/screens/register.dart';

class Login extends StatelessWidget {
  const Login({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController id = TextEditingController();
    final TextEditingController pw = TextEditingController();

    void showMessage(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }

    Future<void> login() async {
      if (id.text.isEmpty || pw.text.isEmpty) {
        showMessage("ID와 PW를 입력해주세요.");
        return;
      }

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: id.text.trim(),
          password: pw.text.trim(),
        );
        showMessage("로그인 성공!");

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainScreen()),
        );
      } on FirebaseAuthException catch (e) {
        showMessage("로그인 실패: ${e.message}");
      } catch (e) {
        showMessage("예기치 못한 오류 발생");
        print(e);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("로그인 페이지"),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          width: 300,
          height: 500,
          padding: const EdgeInsets.all(16.0),
          color: Colors.blue[200],
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text("로그인", style: TextStyle(fontSize: 24)),
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
              const SizedBox(height: 30),

              // 로그인 버튼
              GestureDetector(
                onTap: login,
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text("로그인")),
                ),
              ),

              const SizedBox(height: 10),

              // 회원가입 버튼
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const Register()),
                  );
                },
                child: Container(
                  width: 120,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(child: Text("회원가입")),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}
