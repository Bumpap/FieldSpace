class UserList {
  final String userID;

  UserList({
    required this.userID,
  });

  factory UserList.fromJson(Map<String, dynamic> json) {
    return UserList(
      userID: json['userID'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userID': userID,
    };
  }
}
