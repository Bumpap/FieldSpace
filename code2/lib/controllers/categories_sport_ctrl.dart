import 'package:code2/data/api/api_categoreis.dart';
import 'package:code2/data/repos/categories_sport_repo.dart';
import 'package:get/get.dart';

class CategoriesSportCtrl extends GetxController {
  final ApiCategories _api = Get.find();

  RxList<CategoriesSportRepo> items = RxList<CategoriesSportRepo>();

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  void fetchData() async {
    var data = await _api.getData();
    items.assignAll(data);
  }
}
