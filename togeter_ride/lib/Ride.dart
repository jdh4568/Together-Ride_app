import 'package:cloud_firestore/cloud_firestore.dart';

class Ride {
  final String rideId;
  final String leaderUid;
  final String currentLeaderUid;
  final String groupId;
  final DateTime startedAt;
  final String status; // "진행중", "종료"

  Ride({
    required this.rideId,
    required this.leaderUid,
    required this.currentLeaderUid,
    required this.groupId,
    required this.startedAt,
    required this.status,
  });

  // Firestore용 toMap()
  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'leaderUid': leaderUid,
      'currentLeaderUid': currentLeaderUid,
      'groupId': groupId,
      'startedAt': Timestamp.fromDate(startedAt),
      'status': status,
    };
  }

  // Firestore snapshot → Ride 객체 변환
  factory Ride.fromMap(String docId, Map<String, dynamic> map) {
    return Ride(
      rideId: docId,
      leaderUid: map['leaderUid'],
      currentLeaderUid: map['currentLeaderUid'],
      groupId: map['groupId'],
      startedAt: (map['startedAt'] as Timestamp).toDate(),
      status: map['status'],
    );
  }
}
