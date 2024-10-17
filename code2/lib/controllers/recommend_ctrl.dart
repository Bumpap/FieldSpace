import 'package:code2/data/api/api_recommend.dart';
import 'package:code2/data/repos/recommend_repo.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_rx/get_rx.dart';

import '../data/api/api_sport_field.dart';
import '../data/repos/sport_field_repo.dart';

class RecommendCtrl extends GetxController {
  final ApiRecommend _apiRecommend = Get.find();
  RxList<RecommendRepo> items = RxList<RecommendRepo>();
  final RxMap<String, String> _addresses = <String, String>{}.obs;
  final RxMap<String, String> _image = <String, String>{}.obs;
  final RxMap<String, String> _name = <String, String>{}.obs;
  final RxMap<String, int> _commentCounts = <String, int>{}.obs;
  final ApiSportField _apiSportField = Get.find();
  RxList<SportFieldRepo> itemSport = RxList<SportFieldRepo>();
  RxList<Map<String, dynamic>> comments = RxList<Map<String, dynamic>>([]);
  RxMap<String, List<Map<String, dynamic>>> commentsMap =
      <String, List<Map<String, dynamic>>>{}.obs;
  RxDouble rating = 0.0.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchDataSport();
  }

  void fetchData() async {
    var data = await _apiRecommend.getData();
    items.assignAll(data);

    for (var item in items) {
      if (!_addresses.containsKey(item.sport_field_id)) {
        var address =
            await _apiRecommend.getSportFieldAddress(item.sport_field_id);
        _addresses[item.sport_field_id] = address;
      }
    }

    for (var item in items) {
      if (!_image.containsKey(item.sport_field_id)) {
        var image = await _apiRecommend.getSportFieldImage(item.sport_field_id);
        _image[item.sport_field_id] = image;
      }
    }

    for (var item in items) {
      if (!_name.containsKey(item.sport_field_id)) {
        var name = await _apiRecommend.getSportFieldName(item.sport_field_id);
        _name[item.sport_field_id] = name;
      }
    }

    for (var item in items) {
      int commentCount = await _apiRecommend
          .getCommentsExNull(item.sport_field_id)
          .then((comments) => comments.length);
      _commentCounts[item.sport_field_id] = commentCount;
      commentsMap[item.sport_field_id] =
          await _apiRecommend.getCommentsExNull(item.sport_field_id);
    }
    update();
  }

  void fetchDataSport() async {
    var data = await _apiSportField.getData();
    if (data.isNotEmpty) {
      itemSport.clear();
      itemSport.assignAll(data);
      update();
    } else {
      print('No data found');
    }
  }

  Future<void> fetchRating(String sportFieldId) async {
    try {
      final data = await _apiRecommend
          .getData(); // Ensure this method includes rating information
      final sportField =
          data.firstWhereOrNull((item) => item.sport_field_id == sportFieldId);
      if (sportField != null) {
        rating.value = sportField.rating.toDouble();
      }
      update();
    } catch (e) {
      print('Error fetching rating: $e');
    }
  }

  List<String> getSuggestions(String query) {
    if (query.isEmpty) {
      return [];
    }
    return itemSport
        .where(
            (item) => item.spname.toLowerCase().contains(query.toLowerCase()))
        .map((item) => item.spname)
        .toList();
  }

  String getSportFieldAddress(String sportFieldId) {
    return _addresses[sportFieldId] ?? 'Address not found';
  }

  String getSportFieldImage(String sportFieldId) {
    return _image[sportFieldId] ?? 'Image not found';
  }

  String getSportFieldName(String sportFieldId) {
    return _name[sportFieldId] ?? 'Name not found';
  }

  String? getSportFieldIdByName(String name) {
    return itemSport.firstWhereOrNull((item) => item.spname == name)?.id;
  }

  Future<void> handleSuggestionSelected(String sportFieldId) async {
    var existingRecommend =
        items.firstWhereOrNull((item) => item.sport_field_id == sportFieldId);

    if (existingRecommend == null) {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      await _apiRecommend.createRecommendation(sportFieldId, userId);
      fetchData();
    }
  }

  Future<void> fetchComments(String sportFieldId) async {
    final loadedComments = await _apiRecommend.getComments(sportFieldId);
    comments.assignAll(loadedComments);
  }

  Future<void> addComment(String sportFieldId, String commentText) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    await _apiRecommend.addComment(sportFieldId, commentText, userId);
    fetchComments(sportFieldId);
  }

  Future<void> deleteComment(String sportFieldId, String commentId) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    await _apiRecommend.deleteComment(
        sportFieldId, userId, int.parse(commentId));
    fetchComments(sportFieldId);
  }

  Future<void> updateComment(
      String sportFieldId, String commentId, String newCommentText) async {
    String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
    await _apiRecommend.updateComment(
        sportFieldId, userId, int.parse(commentId), newCommentText);
    fetchComments(sportFieldId);
  }

  Future<void> updateSportFieldRating(
      String sportFieldId, String userId, bool isLiked) async {
    await _apiRecommend.updateSportFieldRating(sportFieldId, userId, isLiked);
    fetchData();
  }

  double calculateRating(int rating) {
    double points = rating * 0.1;
    fetchData();
    return points > 5.0 ? 5.0 : points;
  }

  int getCommentCount(String sportFieldId) {
    fetchData();
    return _commentCounts[sportFieldId] ?? 0;
  }

  Future<Map<String, dynamic>> getSportFieldDetails(String sportFieldId) async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user';
      final details =
          await _apiRecommend.getSportFieldDetails(sportFieldId, userId);
      update();
      return details;
    } catch (e) {
      print('Error fetching sport field details: $e');
      return {};
    }
  }

  Future<void> updateCommentLikeStatus(String sportFieldId, String commentId,
      String userId, bool isLiked) async {
    await _apiRecommend.updateCommentLikeStatus(
        sportFieldId, commentId, userId, isLiked);
    fetchData();
  }
}
