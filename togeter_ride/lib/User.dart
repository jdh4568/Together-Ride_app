import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String nickname;
  final String gender;
  final int age;
  final bool isLeader;
  final bool isFrontRider;
  final bool inGroup;

  UserModel({
    required this.email,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.isLeader,
    required this.isFrontRider,
    required this.inGroup,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      isLeader: data['isLeader'] ?? false,
      isFrontRider: data['isFrontRider'] ?? false,
      inGroup: data['inGroup'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'gender': gender,
      'age': age,
      'isLeader': isLeader,
      'isFrontRider': isFrontRider,
      'inGroup': inGroup,
    };
  }
}

// Firestore에서 UID로 사용자 정보 읽어오는 헬퍼
Future<UserModel?> fetchUserData(String uid) async {
  final doc = await FirebaseFirestore.instance
      .collection('users')
      .doc(uid)
      .get();
  if (doc.exists && doc.data() != null) {
    // doc.data()는 Map<String, dynamic>
    return UserModel.fromMap(doc.data()!);
  }
  return null;
}
