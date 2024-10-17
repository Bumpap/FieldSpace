import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/models/user_list.dart';

class Comment {
  final int idcmt;
  final String userID;
  final List<UserList> ratingcmt;
  final String comment;
  final Timestamp timestamp;
  final bool isLikeField;

  Comment({
    required this.idcmt,
    required this.userID,
    required this.ratingcmt,
    required this.comment,
    required this.timestamp,
    required this.isLikeField,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    List<UserList> ratingcmtList = [];
    if (json['ratingcmt'] is List) {
      ratingcmtList = (json['ratingcmt'] as List)
          .map((item) =>
              item is Map<String, dynamic> ? UserList.fromJson(item) : null)
          .where((item) => item != null)
          .cast<UserList>()
          .toList();
    }

    return Comment(
      idcmt: json['idcmt'] ?? 0,
      userID: json['userID'] ?? '',
      ratingcmt: ratingcmtList,
      comment: json['comment'] ?? '',
      timestamp: json['timestamp'] ?? Timestamp.now(),
      isLikeField: json['isLikeField'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idcmt': idcmt,
      'userID': userID,
      'ratingcmt': ratingcmt.map((item) => item.toJson()).toList(),
      'comment': comment,
      'timestamp': timestamp,
      'isLikeField': isLikeField,
    };
  }
}
