import 'package:code2/controllers/group_ctrl.dart';
import 'package:code2/controllers/users_ctrl.dart';
import 'package:code2/theme.dart';
import 'package:code2/widgets/big_text7.dart';
import 'package:code2/widgets/small_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';

import '../../components/empty_data_view.dart';
import '../../models/demensions.dart';
import '../../widgets/big_text4.dart';
import 'package:code2/route/route_view.dart';

class GroupView extends StatelessWidget {
  final GroupCtrl controller = Get.put(GroupCtrl());
  final UsersCtrl usersCtrl = Get.put(UsersCtrl());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      usersCtrl.fetchAllUsers();
      usersCtrl.fetchCurrentUser();
      controller.fetchGroupsByUserIDOrCoachUser();
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor500,
        title: BigText7(text: 'Manager Groups'),
        automaticallyImplyLeading: false,
        actions: [
          Obx(() {
            final user = usersCtrl.currentUser.value;
            return (user != null && user.role == "coach")
                ? IconButton(
                    icon: Icon(Icons.notifications, color: Colors.white),
                    onPressed: () {}
                    // => _showNotificationDialog(context),
                    )
                : SizedBox.shrink();
          }),
        ],
      ),
      body: Obx(() {
        final user = usersCtrl.currentUser.value;

        if (user == null) {
          return Container(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.5,
                    margin: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.05,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                        MediaQuery.of(context).size.width * 0.05,
                      ),
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: AssetImage(
                            "assets/images/onboarding_illustration.png"),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(RouteView.getSignInView());
                    },
                    child: Container(
                      width: double.maxFinite,
                      height: Demensions.height20 * 5,
                      margin: EdgeInsets.only(
                        left: Demensions.width20,
                        right: Demensions.width20,
                      ),
                      decoration: BoxDecoration(
                        color: primaryColor500,
                        borderRadius:
                            BorderRadius.circular(Demensions.radius20),
                      ),
                      child: Center(
                        child: BigText7(
                          text: "Sign in",
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Stack(
          children: [
            SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                children: [
                  controller.groups.isEmpty
                      ? Container(
                          height: MediaQuery.of(context).size.height / 1.5,
                          child: EmptyDataView(
                            text: "No Groups Available",
                            imgEmpty:
                                "assets/images/no_transaction_illustration.png",
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,
                          padding: EdgeInsets.all(Demensions.width20),
                          itemCount: controller.groups.length,
                          itemBuilder: (context, index) {
                            final group = controller.groups[index];
                            return GestureDetector(
                              onTap: () =>
                                  _showMembersDialog(context, group['id']),
                              child: Container(
                                margin: EdgeInsets.only(
                                    bottom: Demensions.height20),
                                padding: EdgeInsets.all(Demensions.width20),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(
                                      Demensions.radius16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: Demensions.height30 * 2.5,
                                      width: Demensions.width20 * 2.5,
                                      decoration: BoxDecoration(
                                        color: primaryColor500,
                                        borderRadius: BorderRadius.circular(
                                            Demensions.radius16 / 2),
                                      ),
                                      child: Center(
                                        child: Icon(Icons.group,
                                            size: 40, color: Colors.white),
                                      ),
                                    ),
                                    SizedBox(width: Demensions.width20),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          BigText4(text: group['name']),
                                          SizedBox(height: Demensions.height10),
                                          SmallText(text: 'ID: ${group['id']}'),
                                        ],
                                      ),
                                    ),
                                    if (user.role == "coach")
                                      IconButton(
                                        icon: Icon(Icons.edit,
                                            color: primaryColor500),
                                        onPressed: () => _showEditGroupDialog(
                                            context,
                                            group['id'],
                                            group['name']),
                                      ),
                                    if (user.role == "coach")
                                      IconButton(
                                        icon: Icon(Icons.delete,
                                            color: Colors.red),
                                        onPressed: () => _showDeleteGroupDialog(
                                            context, group['id']),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ],
              ),
            ),
            Positioned(
              bottom: Demensions.height20,
              right: Demensions.width20,
              child: Obx(() {
                final user = usersCtrl.currentUser.value;
                return (user != null && user.role == "coach")
                    ? FloatingActionButton(
                        backgroundColor: primaryColor500,
                        child: Icon(Icons.add, color: Colors.white),
                        onPressed: () => _showAddGroupDialog(context),
                      )
                    : Container();
              }),
            ),
          ],
        );
      }),
    );
  }

  void _showAddGroupDialog(BuildContext context) {
    final TextEditingController nameController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add Group'),
        content: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Group name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.addGroup(nameController.text);
              Navigator.of(context).pop();
            },
            child: Text('Add'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showEditGroupDialog(
      BuildContext context, String groupId, String oldName) {
    final TextEditingController nameController =
        TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update Group'),
        content: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: TextField(
            controller: nameController,
            decoration: InputDecoration(labelText: 'Group name'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.updateGroup(groupId, nameController.text);
              Navigator.of(context).pop();
            },
            child: Text('Update'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showDeleteGroupDialog(BuildContext context, String groupId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Group'),
        content: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Text('Are you sure you want to delete this group?'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.deleteGroup(groupId);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  void _showMembersDialog(BuildContext context, String groupId) async {
    controller.fetchMembers(groupId);
    final user = usersCtrl.currentUser.value;

    String? userRole = '';
    if (user != null) {
      userRole = await controller.getUserRoleMember(user.id);
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Members of group'),
          content: Obx(() {
            return Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: controller.members.length,
                    itemBuilder: (context, index) {
                      final member = controller.members[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: Demensions.height20),
                        padding: EdgeInsets.all(Demensions.width20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(Demensions.radius16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.2),
                              spreadRadius: 2,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              height: Demensions.height30 * 2.5,
                              width: Demensions.width20 * 2.5,
                              decoration: BoxDecoration(
                                color: primaryColor500,
                                borderRadius: BorderRadius.circular(
                                    Demensions.radius16 / 2),
                              ),
                              child: Center(
                                child: Icon(Icons.person,
                                    size: 40, color: Colors.white),
                              ),
                            ),
                            SizedBox(width: Demensions.width20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  BigText4(text: member['name']),
                                  SizedBox(height: Demensions.height10),
                                  SmallText(text: 'Role: ${member['role']}'),
                                ],
                              ),
                            ),
                            if (user?.role == "coach" ||
                                userRole == "Tổ trưởng" ||
                                userRole == "Tổ phó")
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor500),
                                onPressed: () => _showEditMemberDialog(
                                    context,
                                    member['id'],
                                    member['name'],
                                    member['role'],
                                    member['userID']),
                              ),
                            if (user?.role == "coach" ||
                                userRole == "Tổ trưởng" ||
                                userRole == "Tổ phó")
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _showDeleteMemberDialog(
                                    context, member['id']),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            );
          }),
          actions: [
            if (user?.role == "coach" ||
                userRole == "Tổ trưởng" ||
                userRole == "Tổ phó")
              TextButton(
                onPressed: () => _showAddMemberDialog(context, groupId),
                child: Text('Add member'),
              ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMemberDialog(BuildContext context, String groupId) {
    final TextEditingController nameController = TextEditingController();
    String selectedRole = 'Thành viên';
    String selectedUserId = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Add member'),
            content: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(Demensions.height10 - 2),
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Search name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Demensions.radius16 / 2),
                          ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        return usersCtrl.getSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion['email']!),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        nameController.text = suggestion['name']!;
                        selectedUserId = suggestion['id']!;
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedRole,
                    items: ['Thành viên', 'Tổ trưởng', 'Tổ phó']
                        .map((String role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      setState(() {
                        selectedRole = value!;
                      });
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.addMember(groupId, nameController.text,
                      selectedRole, selectedUserId);
                  Navigator.of(context).pop();
                },
                child: Text('Add'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showEditMemberDialog(BuildContext context, String memberId,
      String oldName, String oldRole, String oldUserId) {
    final TextEditingController nameController =
        TextEditingController(text: oldName);
    String selectedRole = oldRole;
    String selectedUserId = oldUserId;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return AlertDialog(
            title: Text('Update member'),
            content: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: EdgeInsets.all(Demensions.height10 - 2),
                    child: TypeAheadField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'Search name',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.circular(Demensions.radius16 / 2),
                          ),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        return usersCtrl.getSuggestions(pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(suggestion['name']!),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        nameController.text = suggestion['name']!;
                        selectedUserId = suggestion['id']!;
                      },
                    ),
                  ),
                  DropdownButton<String>(
                    value: selectedRole,
                    items: ['Thành viên', 'Tổ trưởng', 'Tổ phó']
                        .map((role) => DropdownMenuItem<String>(
                              value: role,
                              child: Text(role),
                            ))
                        .toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedRole = value;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  controller.updateMember(memberId, nameController.text,
                      selectedRole, selectedUserId);
                  Navigator.of(context).pop();
                },
                child: Text('Update'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDeleteMemberDialog(BuildContext context, String memberId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete member'),
        content: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Text('Are you sure you want to delete this member?'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.deleteMember(memberId);
              Navigator.of(context).pop();
            },
            child: Text('Delete'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
