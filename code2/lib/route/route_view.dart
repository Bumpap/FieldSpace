import 'package:code2/modules/account/sign_in_view.dart';
import 'package:code2/modules/address/address_view.dart';
import 'package:code2/modules/address/pick_address_map.dart';
import 'package:code2/modules/cart/cart_view.dart';
import 'package:code2/modules/cart/history_admin_view.dart';
import 'package:code2/modules/recommended/recommended_detail_view.dart';
import 'package:code2/modules/search&managefield/create_field.dart';
import 'package:code2/modules/search&managefield/update_field.dart';
import 'package:code2/modules/spash/on_board.dart';
import 'package:code2/modules/spash/spash_view.dart';
import 'package:code2/modules/sport/sport_field_book.dart';
import 'package:code2/modules/sport/recommend_sport_detail.dart';
import 'package:get/get.dart';

import '../modules/account/account_user_view.dart';
import '../modules/account/change_password_view.dart';
import '../modules/account/forgot_password_view.dart';
import '../modules/home/admin_view.dart';

class RouteView {
  static const String home = "/";
  static const String spash = "/spash_view";
  static const String recommend_book = "/recommend_sport_detail";
  static const String cartView = "/cart_view";
  static const String field_book = "/sport_field_book";
  static const String sign_in = "/sign_in_view";
  static const String create_field = "/create_field";
  static const String update_field = "/update_field";
  static const String recommended_detail = "/recommended_detail_view";
  static const String forgot_view = "/forgot_password_view";
  static const String change_pass_view = '/change_password_view';
  static const String address_view = '/address_view';
  static const String adminPage = "/admin_view";
  static const String pickMap = "/pick_address_map";
  static const String adminHistory = "/history_admin_view";
  static const String accountUser = "/account_user_view";

  static String getSpashView() => '$spash';

  static String getHome() => '$home';

  static String getRecomended(String id) => '$recommend_book?id=$id';

  static String getFieldBook(String id) => '$field_book?id=$id';

  static String getCartView() => '$cartView';

  static String getSignInView() => '$sign_in';

  static String getCreateFieldView(String cateid) =>
      '$create_field?cateid=$cateid';

  static String getUpdateFieldView(String id) => '$update_field?id=$id';

  static String getRecommendedDetail(String id) => '$recommended_detail?id=$id';

  static String getForGotView() => '$forgot_view';

  static String getChangePassWordView() => '$change_pass_view';

  static String getAddress() => '$address_view';

  static String getAdminPage() => '$adminPage';

  static String getPickMap() => '$pickMap';

  static String getAddminHistory() => '$adminHistory';

  static String getAccountUser() => '$accountUser';

  static List<GetPage> routes = [
    GetPage(name: spash, page: () => SpashView()),
    GetPage(name: home, page: () => OnBoard()),
    GetPage(
        name: sign_in, page: () => SignInView(), transition: Transition.fadeIn),
    GetPage(name: adminPage, page: () => AdminView()),
    GetPage(
        name: forgot_view,
        page: () => ForgotPasswordView(),
        transition: Transition.fadeIn),
    GetPage(
        name: change_pass_view,
        page: () => ChangePasswordView(),
        transition: Transition.fadeIn),
    GetPage(
        name: address_view,
        page: () => AddressView(),
        transition: Transition.fadeIn),
    GetPage(
        name: recommend_book,
        page: () {
          var id = Get.parameters['id'];
          return RecommendSportDetail(id: id!);
        },
        transition: Transition.fadeIn),
    GetPage(
        name: field_book,
        page: () {
          var id = Get.parameters['id'];
          return SportFieldBook(id: id!);
        },
        transition: Transition.fadeIn),
    GetPage(
        name: create_field,
        page: () {
          var cateid = Get.parameters['cateid'];
          return CreateField(cateid: cateid!);
        },
        transition: Transition.fadeIn),
    GetPage(
        name: update_field,
        page: () {
          var id = Get.parameters['id'];
          return UpdateField(id: id!);
        },
        transition: Transition.fadeIn),
    GetPage(
        name: adminHistory,
        page: () => HistoryAdminView(),
        transition: Transition.fadeIn),
    GetPage(
        name: accountUser,
        page: () => AccountUserView(),
        transition: Transition.fadeIn),
    GetPage(
      name: recommended_detail,
      page: () {
        var id = Get.parameters['id'];
        return RecommendedDetailView(id: id!);
      },
      transition: Transition.fadeIn,
    ),
    GetPage(
        name: cartView,
        page: () {
          return CartView();
        },
        transition: Transition.fadeIn),
    GetPage(
        name: pickMap,
        page: () {
          PickAddressMap _pickMap = Get.arguments;
          return _pickMap;
        })
  ];
}
