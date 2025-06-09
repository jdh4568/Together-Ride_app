import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String email;
  final String nickname;
  final String gender;
  final int age;

  UserModel({
    required this.email,
    required this.nickname,
    required this.gender,
    required this.age,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
    );
  }
}

Future<UserModel?> fetchUserData(String uid) async {
  DocumentSnapshot<Map<String, dynamic>> userDoc =
  await FirebaseFirestore.instance.collection('users').doc(uid).get();

  if (userDoc.exists && userDoc.data() != null) {
    return UserModel.fromMap(userDoc.data()!);
  } else {
    return null;
  }
}
