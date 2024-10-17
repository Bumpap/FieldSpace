import 'package:code2/controllers/cart_field_ctrl.dart';
import 'package:code2/controllers/categories_sport_ctrl.dart';
import 'package:code2/controllers/checkout_ctrl.dart';
import 'package:code2/controllers/group_ctrl.dart';
import 'package:code2/controllers/location_ctrl.dart';
import 'package:code2/controllers/recommend_ctrl.dart';
import 'package:code2/controllers/sport_field_ctrl.dart';
import 'package:code2/controllers/users_ctrl.dart';
import 'package:code2/data/api/api_categoreis.dart';
import 'package:code2/data/api/api_checkout.dart';
import 'package:code2/data/api/api_group.dart';
import 'package:code2/data/api/api_location.dart';
import 'package:code2/data/api/api_recommend.dart';
import 'package:code2/data/api/api_sport_field.dart';
import 'package:code2/data/api/api_users.dart';
import 'package:get/get.dart';

import '../data/api/api_cart_field.dart';

class Dependencies {
  static void init() {
    Get.lazyPut(() => ApiCheckout());
    Get.lazyPut(() => CheckoutCtrl());
    Get.lazyPut(() => CategoriesSportCtrl());
    Get.lazyPut(() => ApiCategories());
    Get.lazyPut<ApiSportField>(() => ApiSportField());
    Get.lazyPut<SportFieldCtrl>(() => SportFieldCtrl());
    Get.lazyPut(() => ApiCartField());
    Get.lazyPut(() => CartFieldCtrl());
    Get.lazyPut(() => ApiUsers());
    Get.lazyPut(() => UsersCtrl());
    Get.lazyPut(() => ApiRecommend());
    Get.lazyPut(() => RecommendCtrl());
    Get.lazyPut(() => LocationCtrl());
    Get.lazyPut(() => ApiLocation());
    Get.lazyPut(() => GroupCtrl());
    Get.lazyPut(() => ApiGroup());
  }
}
