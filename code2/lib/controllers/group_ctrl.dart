import 'package:code2/data/api/api_group.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class GroupCtrl extends GetxController {
  final ApiGroup _api = ApiGroup();
  var groups = <Map<String, dynamic>>[].obs;
  var members = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchGroupsByUserIDOrCoachUser();
  }

  void fetchGroupsByUserIDOrCoachUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final userRole = await _api.getUserRole(user.uid);
      if (userRole == 'coach') {
        fetchGroups();
      } else {
        fetchGroupsByUserID(user.uid);
      }
    }
  }

  void fetchGroups() {
    _api.getGroups().listen((data) {
      groups.value = data;
    });
  }

  void fetchGroupsByUserID(String userID) {
    _api.getGroupsByUserID(userID).listen((data) {
      groups.value = data;
    });
  }

  void fetchMembers(String groupId) {
    _api.getMembers(groupId).listen((data) {
      members.value = data;
    });
  }

  Future<String?> getUserRoleMember(String userID) async {
    final userRole = await _api.getUserRoleMember(userID);
    return userRole;
  }

  void addGroup(String name) async {
    await _api.addGroup(name);
  }

  void deleteGroup(String groupId) async {
    await _api.deleteGroup(groupId);
  }

  void updateGroup(String groupId, String newName) async {
    await _api.updateGroup(groupId, newName);
  }

  void addMember(
      String groupId, String name, String role, String userID) async {
    await _api.addMember(groupId, name, role, userID);
  }

  void deleteMember(String memberId) async {
    await _api.deleteMember(memberId);
  }

  void updateMember(
      String memberId, String newName, String newRole, String userID) async {
    await _api.updateMember(memberId, newName, newRole, userID);
  }
}
