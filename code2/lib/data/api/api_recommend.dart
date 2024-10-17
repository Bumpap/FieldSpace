import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/data/repos/recommend_repo.dart';
import 'package:get/get.dart';

import '../../models/comment.dart';

class ApiRecommend extends GetConnect implements GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final DocumentReference _counterDoc = FirebaseFirestore.instance.collection('meta').doc('commentCounter');

  Future<List<RecommendRepo>> getData() async {
    try {
      QuerySnapshot snapshot = await _firestore.collection('recomended').get();
      return snapshot.docs.map((doc) => RecommendRepo.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  Future<String> getSportFieldAddress(String sportFieldId) async {
    DocumentSnapshot doc = await _firestore.collection('sportfield').doc(sportFieldId).get();
    return doc['address'] ?? 'Address not found';
  }

  Future<double?> getSportFieldRating(String sportFieldId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var doc = querySnapshot.docs.first;
        return doc['rating']?.toDouble(); // Ensure it's a double
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching rating: $e');
      return null;
    }
  }

  Future<String> getSportFieldImage(String sportFieldId) async {
    DocumentSnapshot doc = await _firestore.collection('sportfield').doc(sportFieldId).get();
    return doc['image'] ?? 'Image not found';
  }

  Future<String> getSportFieldName(String sportFieldId) async {
    DocumentSnapshot doc = await _firestore.collection('sportfield').doc(sportFieldId).get();
    return doc['name'] ?? 'Name not found';
  }

  Future<int> _getNextCommentId() async {
    try {
      DocumentSnapshot counterSnapshot = await _counterDoc.get();
      int currentId = counterSnapshot.exists ? (counterSnapshot.data() as Map<String, dynamic>)['currentId'] ?? 0 : 0;
      int nextId = currentId + 1;
      await _counterDoc.set({'currentId': nextId});
      return nextId;
    } catch (e) {
      print('Error getting next comment ID: $e');
      return 1; // Default to 1 in case of error
    }
  }

  Future<void> _resetCommentId() async {
    try {
      await _counterDoc.set({'currentId': 0});
    } catch (e) {
      print('Error resetting comment ID: $e');
    }
  }

  Future<void> createRecommendation(String sportFieldId, String userId) async {
    try {
      await _resetCommentId();

      int newCommentId = await _getNextCommentId();

      final comment = Comment(
          idcmt: newCommentId,
          userID: userId,
          ratingcmt: [],
          comment: '',
          timestamp: Timestamp.now(),
          isLikeField: false
      );

      await _firestore.collection('recomended').add({
        'sport_field_id': sportFieldId,
        'rating': 0,
        'comments': [comment.toJson()],
      });
    } catch (e) {
      print('Error creating recommendation: $e');
    }
  }

  Future<void> addComment(String sportFieldId, String commentText, String userId) async {
    try {
      int newCommentId = await _getNextCommentId();

      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        final doc = await _firestore.collection('recomended').doc(docId).get();
        final data = doc.data();
        final comments = List.from(data?['comments'] ?? []);

        final newComment = Comment(
            idcmt: newCommentId,
            userID: userId,
            ratingcmt: [],
            comment: commentText,
            timestamp: Timestamp.now(),
            isLikeField: false
        );

        comments.add(newComment.toJson());

        await _firestore.collection('recomended').doc(docId).update({
          'comments': comments,
        });
      }
    } catch (e) {
      print('Error adding comment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getComments(String sportFieldId) async {
    try {
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      // Collect all comments, including those with empty text
      final allComments = querySnapshot.docs
          .map((doc) => (doc.data()['comments'] as List)
          .map((comment) => comment as Map<String, dynamic>)
          .toList())
          .expand((element) => element)
          .toList();

      // Filter out comments with empty text before returning
      final filteredComments = allComments.toList();
      // .where((comment) => comment['comment']?.isNotEmpty ?? false)
      // .toList();

      return filteredComments;
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getCommentsExNull(String sportFieldId) async {
    try {
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      final allComments = querySnapshot.docs
          .map((doc) => (doc.data()['comments'] as List)
          .map((comment) => comment as Map<String, dynamic>)
          .toList())
          .expand((element) => element)
          .toList();

      final filteredComments = allComments
          .where((comment) => comment['comment']?.isNotEmpty ?? false)
          .toList();

      return filteredComments;
    } catch (e) {
      print('Error fetching comments: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>> getSportFieldDetails(String sportFieldId, String userId) async {
    try {
      // Check if the recommendation exists
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // No recommendation exists, create a new one
        await createRecommendation(sportFieldId, userId);
      }

      // Retrieve the sport field details
      final sportFieldName = await getSportFieldName(sportFieldId);
      final sportFieldImage = await getSportFieldImage(sportFieldId);
      final sportFieldAddress = await getSportFieldAddress(sportFieldId);
      final sportFieldRating = await getSportFieldRating(sportFieldId);

      return {
        'name': sportFieldName,
        'image': sportFieldImage,
        'address': sportFieldAddress,
        'rating': sportFieldRating
      };
    } catch (e) {
      print('Error fetching sport field details: $e');
      throw e;
    }
  }

  Future<void> deleteComment(String sportFieldId, String userId, int commentId) async {
    try {
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        final doc = await _firestore.collection('recomended').doc(docId).get();
        final data = doc.data();
        final comments = List.from(data?['comments'] ?? []);

        // Find the index of the comment to delete
        final indexToRemove = comments.indexWhere((comment) =>
        comment['userID'] == userId && comment['idcmt'] == commentId);

        if (indexToRemove != -1) {
          comments.removeAt(indexToRemove);

          await _firestore.collection('recomended').doc(docId).update({
            'comments': comments,
          });
        }
      }
    } catch (e) {
      print('Error deleting comment: $e');
    }
  }

  Future<void> updateComment(String sportFieldId, String userId, int commentId, String newCommentText) async {
    try {
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;

        final doc = await _firestore.collection('recomended').doc(docId).get();
        final data = doc.data();
        final comments = List.from(data?['comments'] ?? []);

        // Find the index of the comment to update
        final indexToUpdate = comments.indexWhere((comment) =>
        comment['userID'] == userId && comment['idcmt'] == commentId);

        if (indexToUpdate != -1) {
          // Update the comment text
          comments[indexToUpdate]['comment'] = newCommentText;

          await _firestore.collection('recomended').doc(docId).update({
            'comments': comments,
          });
        }
      }
    } catch (e) {
      print('Error updating comment: $e');
    }
  }

  Future<void> updateSportFieldRating(String sportFieldId, String userId, bool isLiked) async {
    try {
      // Get the document(s) where sport_field_id matches the provided ID
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        bool userCommentFound = false;
        int ratingIncrement = isLiked ? 1 : -1;

        // Iterate through all matching documents
        for (var doc in querySnapshot.docs) {
          final docId = doc.id;
          final docData = doc.data();
          final comments = List.from(docData['comments'] ?? []);

          // Iterate through all comments in the document
          for (var comment in comments) {
            if (comment['userID'] == userId) {
              // Update the isLikeField status for matching comments
              comment['isLikeField'] = isLiked;
              userCommentFound = true;
            }
          }

          // Update the document with the modified comments list
          await _firestore.collection('recomended').doc(docId).update({
            'comments': comments,
          });
        }

        // If the user comment was not found, add a new comment
        if (!userCommentFound) {
          int newCommentId = await _getNextCommentId();

          final newComment = Comment(
            idcmt: newCommentId,
            userID: userId,
            ratingcmt: [],
            comment: '',
            timestamp: Timestamp.now(),
            isLikeField: isLiked,
          );

          await _firestore.collection('recomended').where('sport_field_id', isEqualTo: sportFieldId).get().then((snapshot) async {
            if (snapshot.docs.isNotEmpty) {
              final docId = snapshot.docs.first.id;

              final doc = await _firestore.collection('recomended').doc(docId).get();
              final data = doc.data();
              final comments = List.from(data?['comments'] ?? []);
              comments.add(newComment.toJson());

              await _firestore.collection('recomended').doc(docId).update({
                'comments': comments,
              });
            }
          });
        }

        // Calculate the new rating for the sport field
        int newRating = querySnapshot.docs.fold<int>(0, (sum, doc) {
          final currentRating = doc.data()['rating'] as int? ?? 0;
          return sum + currentRating + ratingIncrement;
        });

        // Update the rating in all relevant documents
        for (var doc in querySnapshot.docs) {
          await _firestore.collection('recomended').doc(doc.id).update({
            'rating': newRating,
          });
        }
      }
    } catch (e) {
      print('Error updating sport field rating: $e');
    }
  }

  Future<void> updateCommentLikeStatus(String sportFieldId, String commentId, String userId, bool isLiked) async {
    try {
      final querySnapshot = await _firestore
          .collection('recomended')
          .where('sport_field_id', isEqualTo: sportFieldId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          final docId = doc.id;
          final docData = doc.data();
          final comments = List.from(docData['comments'] ?? []);

          final commentIndex = comments.indexWhere((c) => c['idcmt'].toString() == commentId);

          if (commentIndex != -1) {
            final comment = comments[commentIndex];
            List<String> ratingcmt = List.from(comment['ratingcmt'] ?? []);

            if (isLiked) {
              if (!ratingcmt.contains(userId)) {
                ratingcmt.add(userId);
              }
            } else {
              ratingcmt.remove(userId);
            }

            comments[commentIndex]['ratingcmt'] = ratingcmt;

            await _firestore.collection('recomended').doc(docId).update({
              'comments': comments,
            });
          }
        }
      }
    } catch (e) {
      print('Error updating comment like status: $e');
    }
  }

}
