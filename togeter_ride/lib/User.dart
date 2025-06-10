class UserModel {
  final String email;
  final String nickname;
  final String gender;
  final int age;
  final bool isLeader;       // 그룹장 여부
  final bool isFrontRider;   // 선두 라이더 여부

  UserModel({
    required this.email,
    required this.nickname,
    required this.gender,
    required this.age,
    required this.isLeader,
    required this.isFrontRider,
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      email: data['email'] ?? '',
      nickname: data['nickname'] ?? '',
      gender: data['gender'] ?? '',
      age: data['age'] ?? 0,
      isLeader: data['isLeader'] ?? false,
      isFrontRider: data['isFrontRider'] ?? false,
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
    };
  }
}
