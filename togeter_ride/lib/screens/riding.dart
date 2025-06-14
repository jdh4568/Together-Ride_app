import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Riding extends StatelessWidget {
  const Riding({super.key});

  void _endRide(BuildContext context) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 현재 사용자가 리더인 경우, 해당 rideRequest의 상태를 종료로 설정
    final rideQuery = await FirebaseFirestore.instance
        .collection('ride_requests')
        .where('leaderUid', isEqualTo: uid)
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (rideQuery.docs.isNotEmpty) {
      final rideDoc = rideQuery.docs.first.reference;
      await rideDoc.update({'status': '종료'});
    }

    // 모든 참여자의 상태를 '종료됨'으로 업데이트
    final participantSnapshot = await FirebaseFirestore.instance
        .collectionGroup('participants')
        .where('uid', isEqualTo: uid)
        .get();

    for (var doc in participantSnapshot.docs) {
      await doc.reference.update({'status': '종료됨'});
    }

    if (context.mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("라이딩 화면"), centerTitle: true),
      body: Center(
        child: GestureDetector(
          onTap: () => _endRide(context),
          child: Container(
            color: Colors.red,
            height: 100,
            width: 100,
            child: const Center(
              child: Text(
                "라이딩 종료",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
