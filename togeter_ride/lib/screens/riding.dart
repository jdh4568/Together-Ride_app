import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Riding extends StatelessWidget {
  const Riding({super.key});

  void _endRide(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 현재 사용자가 리더인 경우, 해당 rideRequest의 상태를 종료로 설정
    final rideQuery = await FirebaseFirestore.instance.collection('ride_requests').where('leaderUid', isEqualTo: uid).orderBy('createdAt', descending: true).limit(1).get();

    if (rideQuery.docs.isNotEmpty) {
      final rideDoc = rideQuery.docs.first.reference;
      await rideDoc.update({'status': '종료'});
    }

    // 모든 참여자의 상태를 '종료됨'으로 업데이트
    final participantSnapshot = await FirebaseFirestore.instance.collectionGroup('participants').where('uid', isEqualTo: uid).get();

    for (var doc in participantSnapshot.docs) {
      await doc.reference.update({'status': '종료됨'});
    }

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text("라이딩 화면"), centerTitle: true),
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
        child: Column(
            children: [
              SizedBox(height: 30,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignalButton(label: "좌로 진행"),
                  SizedBox(width: 3,),
                  SignalButton(label: "우로 진행"),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignalButton(label: "한줄로"),
                  SizedBox(width: 3,),
                  SignalButton(label: "두줄로"),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignalButton(label: "노면 조심"),
                  SizedBox(width: 3,),
                  SignalButton(label: "서행"),
                ],
              ),
              SizedBox(height: 5,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SignalButton(label: "정지"),
                  SizedBox(width: 3,),
                  SignalButton(label: "선두 교체"),
                ],
              ),
              SizedBox(height: 30,),
              Container(
                child: Center(child: Text("속도계", style: TextStyle(fontSize: 25),),),
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
                  color: Colors.grey,
                ),
                height: 150,
                width: 250,
              ),
              SizedBox(height: 30,),
              endRiding(context),
            ],
          ),
      ),
      );
  }

  // endRiding(context), <- 사용 코드
  GestureDetector endRiding(BuildContext context) {
    return GestureDetector(
      onTap: () => _endRide(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey,
          border: Border.all(color: Colors.black),
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

        height: 100,
        width: 200,
        child: const Center(
          child: Text("라이딩 종료", style: TextStyle(fontSize: 25)),
        ),
      ),
    );
  }
}
class SignalButton extends StatefulWidget {
  final String label;

  const SignalButton({super.key, required this.label});

  @override
  State<SignalButton> createState() => _SignalButtonState();
}

class _SignalButtonState extends State<SignalButton> {
  Color _currentColor = Colors.grey;
  bool _isBlinking = false;

  void _blink() async {
    if (_isBlinking) return;
    _isBlinking = true;
    for (int i = 0; i < 10; i++) {
      await Future.delayed(Duration(seconds: 1));
      setState(() {
        _currentColor = _currentColor == Colors.red ? Colors.grey : Colors.red;
      });
    }
    setState(() {
      _currentColor = Colors.grey;
      _isBlinking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _blink,
      child: Container(
        child: Center(child: Text(widget.label, style: TextStyle(fontSize: 25))),
        decoration: BoxDecoration(
          color: _currentColor,
          border: Border.all(color: Colors.black),
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
        height: 80,
        width: 150,
      ),
    );
  }
}
