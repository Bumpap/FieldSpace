import 'package:cloud_firestore/cloud_firestore.dart';

class ApiGroup {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<Map<String, dynamic>>> getGroupsByUserID(String userID) {
    return _db
        .collection('members')
        .where('userID', isEqualTo: userID)
        .snapshots()
        .asyncMap((membersSnapshot) async {
      final groupIds = membersSnapshot.docs
          .map((doc) => doc.data()['groupId'] as String)
          .toSet()
          .toList();
      final groupsSnapshot = await _db
          .collection('groups')
          .where(FieldPath.documentId, whereIn: groupIds)
          .get();
      return groupsSnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();
    });
  }

  Future<String?> getUserRole(String userID) async {
    try {
      final snapshot = await _db.collection('users').doc(userID).get();
      if (snapshot.exists) {
        return snapshot.data()?['role'] as String?;
      }
    } catch (e) {
      print('Error fetching user role: $e');
    }
    return null;
  }

  Future<String?> getUserRoleMember(String userID) async {
    final snapshot = await _db
        .collection('members')
        .where('userID', isEqualTo: userID)
        .limit(1)
        .get();
    if (snapshot.docs.isNotEmpty) {
      return snapshot.docs.first.data()['role'] as String?;
    }
    return null;
  }

  Future<void> addGroup(String groupName) async {
    await _db.collection('groups').add({
      'name': groupName,
    });
  }

  Future<void> deleteGroup(String groupId) async {
    await _db.collection('groups').doc(groupId).delete();
    final membersSnapshot = await _db
        .collection('members')
        .where('groupId', isEqualTo: groupId)
        .get();
    for (var doc in membersSnapshot.docs) {
      await doc.reference.delete();
    }
  }

  Future<void> updateGroup(String groupId, String newName) async {
    await _db.collection('groups').doc(groupId).update({
      'name': newName,
    });
  }

  Future<void> addMember(
      String groupId, String memberName, String role, String userID) async {
    await _db.collection('members').add({
      'groupId': groupId,
      'name': memberName,
      'role': role,
      'userID': userID,
    });
  }

  Future<void> deleteMember(String memberId) async {
    await _db.collection('members').doc(memberId).delete();
  }

  Future<void> updateMember(
      String memberId, String newName, String newRole, String userID) async {
    await _db
        .collection('members')
        .doc(memberId)
        .update({'name': newName, 'role': newRole, 'userID': userID});
  }

  Stream<List<Map<String, dynamic>>> getGroups() {
    return _db.collection('groups').snapshots().map((snapshot) => snapshot.docs
        .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
        .toList());
  }

  Stream<List<Map<String, dynamic>>> getMembers(String groupId) {
    return _db
        .collection('members')
        .where('groupId', isEqualTo: groupId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList());
  }
}
