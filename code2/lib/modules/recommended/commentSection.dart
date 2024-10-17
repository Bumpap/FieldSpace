import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/recommend_ctrl.dart';
import '../../models/demensions.dart';

class CommentSection extends StatefulWidget {
  final String sportFieldId;

  const CommentSection({super.key, required this.sportFieldId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  bool isLiked = false;
  Color? likeButtonColor = Colors.grey[300];

  final RecommendCtrl recommendCtrl = Get.find<RecommendCtrl>();
  final TextEditingController commentController = TextEditingController();

  Map<String, bool> commentLikeStatus = {};
  Map<String, int> commentLikeCount = {};
  Map<String, Color> commentLikeButtonColor = {};

  @override
  void initState() {
    super.initState();
    recommendCtrl.fetchComments(widget.sportFieldId).then((_) {
      print("Fetched comments: ${recommendCtrl.comments}");
      final userId = FirebaseAuth.instance.currentUser?.uid;
      print("userId: ${userId}");
      if (userId != null) {
        final comment = recommendCtrl.comments.firstWhere(
          (comment) => comment['userID'] == userId,
          orElse: () => {} as Map<String, dynamic>,
        );

        if (comment.isEmpty) {
          print("No comment found for userID: $userId");
        } else {
          print("Comment for userID: ${comment['userID']}");
          setState(() {
            for (var comment in recommendCtrl.comments) {
              String commentId = comment['idcmt'].toString();
              List<String> ratingcmt = List.from(comment['ratingcmt'] ?? []);
              commentLikeStatus[commentId] = ratingcmt.contains(userId);
              print(
                  "commentLikeStatus[commentId]: ${commentLikeStatus[commentId]}");
              commentLikeCount[commentId] = ratingcmt.length;
              commentLikeButtonColor[commentId] = (commentLikeStatus[commentId]!
                  ? Colors.greenAccent
                  : Colors.grey[300])!;
            }
            isLiked = comment['isLikeField'] ?? false;
            likeButtonColor = isLiked ? Colors.red : Colors.grey[300];
          });
        }
      } else {
        print("User ID is null");
      }
    }).catchError((error) {
      print("Error fetching comments: $error");
    });
  }

  bool get isAuthenticated {
    return FirebaseAuth.instance.currentUser != null;
  }

  void _showLoginDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Login Required'),
          content: Text('You need to be logged in to perform this action.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void addComment() async {
    if (!isAuthenticated) {
      _showLoginDialog();
      return;
    }

    String commentText = commentController.text;
    if (commentText.isNotEmpty) {
      await recommendCtrl.addComment(widget.sportFieldId, commentText);
      setState(() {
        commentController.clear();
      });
    }
  }

  void likeComment(int index) async {
    if (!isAuthenticated) {
      _showLoginDialog();
      return;
    }

    final comment = recommendCtrl.comments[index];
    String commentId = comment['idcmt'].toString();
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

    bool currentlyLiked = commentLikeStatus[commentId] ?? false;

    bool newLikeStatus = !currentlyLiked;

    setState(() {
      commentLikeStatus[commentId] = newLikeStatus;
      commentLikeCount[commentId] =
          (commentLikeCount[commentId] ?? 0) + (newLikeStatus ? 1 : -1);
      commentLikeButtonColor[commentId] =
          (newLikeStatus ? Colors.greenAccent : Colors.grey[300])!;
    });

    await recommendCtrl.updateCommentLikeStatus(
        widget.sportFieldId, commentId, userId, newLikeStatus);
  }

  void likeSportField() async {
    if (!isAuthenticated) {
      _showLoginDialog();
      return;
    }

    setState(() {
      isLiked = !isLiked;
      likeButtonColor = isLiked ? Colors.red : Colors.grey[300];
    });

    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';

    await recommendCtrl.updateSportFieldRating(
        widget.sportFieldId, userId, isLiked);
  }

  void deleteComment(int index) async {
    if (!isAuthenticated) {
      _showLoginDialog();
      return;
    }

    String commentId = recommendCtrl.comments[index]['idcmt'].toString();
    await recommendCtrl.deleteComment(widget.sportFieldId, commentId);
  }

  void editComment(int index) {
    if (!isAuthenticated) {
      _showLoginDialog();
      return;
    }

    String commentId = recommendCtrl.comments[index]['idcmt'].toString();
    String commentText = recommendCtrl.comments[index]['comment'];
    commentController.text = commentText;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Comment'),
          content: TextField(
            controller: commentController,
            decoration: InputDecoration(
              hintText: 'Edit comment',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(Demensions.radius16 / 2),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (commentController.text.trim() != commentText) {
                  recommendCtrl.updateComment(widget.sportFieldId, commentId,
                      commentController.text.trim());
                }
                Navigator.of(context).pop();
                commentController.clear();
              },
              child: Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                commentController.clear();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Column(
      children: [
        Expanded(
          child: Obx(() {
            final visibleComments = recommendCtrl.comments
                .where((comment) => comment['comment']?.isNotEmpty ?? false)
                .toList();

            if (visibleComments.isEmpty) {
              return Center(child: Text('No comments yet'));
            }

            return ListView.builder(
              itemCount: visibleComments.length,
              itemBuilder: (context, index) {
                final comment = visibleComments[index];
                final commentId = comment['idcmt'].toString();
                final likeCount = commentLikeCount[commentId] ?? 0;
                final commentUserId = comment['userID'];

                return ListTile(
                  leading: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.favorite,
                          color: commentLikeButtonColor[commentId],
                        ),
                        onPressed: () {
                          final originalIndex = recommendCtrl.comments
                              .indexWhere(
                                  (c) => c['idcmt'] == comment['idcmt']);
                          likeComment(originalIndex);
                        },
                      ),
                      Text('$likeCount'),
                    ],
                  ),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(comment['comment']),
                      ),
                      Row(
                        children: [
                          if (currentUserId == commentUserId) ...[
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                // Find the original index of the comment in recommendCtrl.comments
                                final originalIndex = recommendCtrl.comments
                                    .indexWhere(
                                        (c) => c['idcmt'] == comment['idcmt']);
                                editComment(originalIndex);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.close, color: Colors.red),
                              onPressed: () {
                                final originalIndex = recommendCtrl.comments
                                    .indexWhere(
                                        (c) => c['idcmt'] == comment['idcmt']);
                                deleteComment(originalIndex);
                              },
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          }),
        ),
        Padding(
          padding: EdgeInsets.all(Demensions.radius16 / 2),
          child: Row(
            children: [
              IconButton(
                icon: Icon(Icons.favorite),
                color: likeButtonColor,
                onPressed: () => likeSportField(),
              ),
              SizedBox(width: Demensions.width10),
              Expanded(
                child: TextField(
                  controller: commentController,
                  decoration: InputDecoration(
                    hintText: 'Thêm bình luận...',
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(Demensions.radius16 / 2),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.send),
                onPressed: addComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
