import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:code2/models/comment.dart';
import 'package:get/get.dart';

class RecommendRepo extends GetxService {
  final String id;
  final int rating;
  final String sport_field_id;
  final List<Comment> comments;

  RecommendRepo({
    required this.id,
    required this.rating,
    required this.sport_field_id,
    required this.comments,
  });

  factory RecommendRepo.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    List<Comment> comments = [];
    if (data['comments'] != null && data['comments'] is List) {
      comments = (data['comments'] as List)
          .map((itemData) => itemData is Map<String, dynamic>
              ? Comment.fromJson(itemData)
              : null)
          .where((item) => item != null)
          .cast<Comment>()
          .toList();
    }

    return RecommendRepo(
      id: doc.id,
      rating: data['rating'],
      sport_field_id: data['sport_field_id'],
      comments: comments,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rating': rating,
      'sport_field_id': sport_field_id,
      'comments': comments.map((item) => item.toJson()).toList(),
    };
  }
}
