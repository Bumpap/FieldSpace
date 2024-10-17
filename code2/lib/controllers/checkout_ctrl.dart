import 'package:code2/data/api/api_checkout.dart';
import 'package:code2/data/api/api_sport_field.dart';
import 'package:code2/data/repos/checkout_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class CheckoutCtrl extends GetxController {
  final ApiSportField _apiSportField = Get.find();

  RxList<CheckoutRepo> items = RxList<CheckoutRepo>();
  RxList<CheckoutRepo> allItems = RxList<CheckoutRepo>();
  final RxMap<String, String> _image = <String, String>{}.obs;
  final RxMap<String, String> _allImage = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchData();
    fetchAllData();
  }

  void fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    var data = await Get.find<ApiCheckout>().getData(user!.uid);
    items.assignAll(data);

    for (var item in items) {
      for (var cartItem in item.items) {
        if (!_image.containsKey(cartItem.sportFieldId)) {
          var image =
              await _apiSportField.getSportFieldImage(cartItem.sportFieldId);
          _image[cartItem.sportFieldId] = image;
        }
      }
    }
    update();
  }

  void fetchAllData() async {
    var data = await Get.find<ApiCheckout>().getAllData();
    allItems.assignAll(data);

    for (var item in allItems) {
      for (var cartItem in item.items) {
        if (!_allImage.containsKey(cartItem.sportFieldId)) {
          var image =
              await _apiSportField.getSportFieldImage(cartItem.sportFieldId);
          _allImage[cartItem.sportFieldId] = image;
        }
      }
    }

    update();
  }

  String getImage(String sportFieldId) {
    return _image[sportFieldId] ?? 'Image not found';
  }

  String getAllImage(String sportFieldId) {
    return _allImage[sportFieldId] ?? 'Image not found';
  }
}
