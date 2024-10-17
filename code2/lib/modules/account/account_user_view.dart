import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/controllers/users_ctrl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/show_error_scbar.dart';
import '../../data/api/api_users.dart';
import '../../data/repos/users_repo.dart';
import '../../theme.dart';

class AccountUserView extends StatelessWidget {
  final UsersCtrl usersCtrl = Get.find<UsersCtrl>();

  AccountUserView({Key? key}) : super(key: key);

  void _editUser(BuildContext context, DocumentSnapshot document) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    bool _isPasswordVisible = false;

    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
    nameController.text = data['name'] ?? '';
    emailController.text = data['email'] ?? '';
    passwordController.text = data['password'] ?? '';
    phoneController.text = data['phonenumber'] ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Edit User'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !_isPasswordVisible,
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final name = nameController.text.trim();
                    final email = emailController.text.trim();
                    final password = passwordController.text.trim();
                    final phone = phoneController.text.trim();

                    bool success = true;
                    if (email.isNotEmpty) {
                      try {
                        usersCtrl.updateUserEmailById(email, document.id);
                      } catch (e) {
                        success = false;
                        showErrorScBar("Failed to update password",
                            title: "Error");
                      }
                    }
                    if (password.isNotEmpty) {
                      try {
                        usersCtrl.updateUserPasswordById(password, document.id);
                      } catch (e) {
                        success = false;
                        showErrorScBar("Failed to update password",
                            title: "Error");
                      }
                    }
                    if (name.isNotEmpty) {
                      try {
                        usersCtrl.updateUserNameById(name, document.id);
                      } catch (e) {
                        success = false;
                        showErrorScBar("Failed to update password",
                            title: "Error");
                      }
                    }
                    if (phone.isNotEmpty) {
                      try {
                        usersCtrl.updateUserPhoneById(phone, document.id);
                      } catch (e) {
                        success = false;
                        showErrorScBar("Failed to update password",
                            title: "Error");
                      }
                    }
                    if (success) {
                      Navigator.of(context).pop();
                      Get.snackbar(
                        'Success',
                        'User updated successfully',
                        snackPosition: SnackPosition.TOP,
                        backgroundColor: Colors.green,
                        colorText: Colors.white,
                      );
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDeleteUser(BuildContext context, DocumentSnapshot document) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Delete User'),
          content: Text('Are you sure you want to delete this user?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteUser(document);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteUser(DocumentSnapshot document) {
    try {
      usersCtrl.deleteAuthorUserAndUserCollection(document.id);
      Get.snackbar(
        'Success',
        'User deleted successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      showErrorScBar("Failed to delete user", title: "Error");
    }
  }

  void _addUser() {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final phoneController = TextEditingController();

    bool isPasswordVisible = false;

    showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Add New User'),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        suffixIcon: IconButton(
                          icon: Icon(
                            isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                        ),
                      ),
                      obscureText: !isPasswordVisible,
                    ),
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(labelText: 'Name'),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: InputDecoration(labelText: 'Phone'),
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    String name = nameController.text.trim();
                    String email = emailController.text.trim();
                    String pass = passwordController.text.trim();
                    String nbphone = phoneController.text.trim();

                    if (email.isEmpty) {
                      showErrorScBar("Input your email", title: "Email");
                    } else if (!GetUtils.isEmail(email)) {
                      showErrorScBar("Not email format", title: "Email");
                    } else if (pass.isEmpty) {
                      showErrorScBar("Input your password", title: "Pass");
                    } else if (pass.length < 8) {
                      showErrorScBar(
                          "Your password can not be less than 8 characters",
                          title: "Pass");
                    } else if (name.isEmpty) {
                      showErrorScBar("Input your name", title: "Name");
                    } else if (nbphone.isEmpty) {
                      showErrorScBar("Input your phone", title: "Phone");
                    } else if (!GetUtils.isPhoneNumber(nbphone)) {
                      showErrorScBar("Not phone number format", title: "Phone");
                    } else {
                      try {
                        bool emailExists =
                            await Get.find<ApiUsers>().checkEmailExists(email);
                        bool passwordExists = await Get.find<ApiUsers>()
                            .checkPasswordExists(pass);
                        FirebaseAuth auth = FirebaseAuth.instance;

                        if (emailExists) {
                          showErrorScBar("Email already exists",
                              title: "Email");
                        } else if (passwordExists) {
                          showErrorScBar("Password already exists",
                              title: "Password");
                        } else {
                          UserCredential userCredential =
                              await auth.createUserWithEmailAndPassword(
                            email: email,
                            password: pass,
                          );

                          UsersRepo newUser = UsersRepo(
                            id: userCredential.user!.uid,
                            email: email,
                            password: pass,
                            name: name,
                            phoneNb: nbphone,
                            imagePro: '',
                            role: 'user',
                          );

                          await Get.find<ApiUsers>().addAccount(newUser);

                          Navigator.of(context).pop();

                          Get.snackbar(
                            'User Added',
                            'The new user has been added successfully',
                            snackPosition: SnackPosition.TOP,
                            backgroundColor: Colors.green,
                            colorText: Colors.white,
                          );
                        }
                      } catch (e) {
                        showErrorScBar("Failed to add user", title: "Error");
                      }
                    }
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account User'),
        backgroundColor: primaryColor500,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: _addUser,
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('users').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView(
            children: snapshot.data!.docs.map((DocumentSnapshot document) {
              Map<String, dynamic> data =
                  document.data()! as Map<String, dynamic>;
              return ListTile(
                leading: data['image'] != null
                    ? CircleAvatar(
                        backgroundImage: NetworkImage(data['image']),
                      )
                    : CircleAvatar(child: Icon(Icons.person)),
                title: Text(data['name'] ?? 'No Name'),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${data['email']}'),
                    Text('Phone: ${data['phonenumber'] ?? 'No Phone'}'),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () => _editUser(context, document),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () => _confirmDeleteUser(context, document),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
