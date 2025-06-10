import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GroupPage extends StatelessWidget {
  const GroupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("그룹 관리 화면"), centerTitle: true),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xffB3E5FC), Color(0xff6BF8F3)]),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(

                height: 100,
                width: 300,
                decoration: BoxDecoration(
                  color: Color(0xffF5F3F3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(child: Text("가입된 그룹이 없습니다.\n그룹 가입 또는, 그룹 생성을 해주세요."),),
              ),
              SizedBox(height: 100,),
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  color: Color(0xffF5F3F3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(child: Text("커뮤니티로 이동"),),
              ),
              SizedBox(height: 50,),
              Container(
                height: 100,
                width: 200,
                decoration: BoxDecoration(
                  color: Color(0xffF5F3F3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 2,
                      offset: Offset(0, 3), // changes position of shadow
                    ),
                  ],
                ),
                child: Center(child: Text("그룹 생성"),),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
