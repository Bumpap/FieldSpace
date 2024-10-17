import 'package:get/get.dart';
import '../data/repos/categories_sport_repo.dart';
import '../data/repos/sport_field_repo.dart';
import '../controllers/categories_sport_ctrl.dart';
import '../controllers/sport_field_ctrl.dart';

class SearchViewController extends GetxController {
  final CategoriesSportCtrl categoriesSportCtrl = Get.find();
  final SportFieldCtrl sportFieldCtrl = Get.find();
  var _query = ''.obs;
  var _selectedDropdownItem = 'All'.obs;
  var _fieldList = <SportFieldRepo>[].obs;
  var _selectedListByCategory = <SportFieldRepo>[].obs;
  var _isLoading = false.obs;
  var _suggestions = <SportFieldRepo>[].obs;
  var _searchSuggestions = <SportFieldRepo>[].obs;

  @override
  void onInit() {
    super.onInit();
    _fetchData();
  }

  Future<void> _fetchData() async {
    _isLoading.value = true;
    try {
      sportFieldCtrl.fetchData();
      _fieldList.value = sportFieldCtrl.items;
      _filterFields();
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch data: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void _filterFields() {
    if (_selectedDropdownItem.value == 'All') {
      _selectedListByCategory.value = _fieldList;
    } else {
      String selectedCategoryId = categoriesSportCtrl.items
          .firstWhere(
            (category) => category.spname == _selectedDropdownItem.value,
            orElse: () =>
                CategoriesSportRepo(id: '', spname: 'Unknown', image: ''),
          )
          .id;

      if (selectedCategoryId.isEmpty) {
        _selectedListByCategory.value = [];
      } else {
        _selectedListByCategory.value = _fieldList
            .where((field) => field.categories == selectedCategoryId)
            .toList();
      }
    }

    _suggestions.value = _fieldList
        .where((field) =>
            field.spname.toLowerCase().contains(_query.value.toLowerCase()))
        .toList();
  }

  String get query => _query.value;

  set query(String value) {
    _query.value = value;
    _updateSearchSuggestions();
    _filterFields();
  }

  String get selectedDropdownItem => _selectedDropdownItem.value;

  set selectedDropdownItem(String value) {
    _selectedDropdownItem.value = value;
    _filterFields();
  }

  List<SportFieldRepo> get selectedListByCategory => _selectedListByCategory;

  List<SportFieldRepo> get suggestions => _suggestions;

  List<SportFieldRepo> get searchSuggestions =>
      _searchSuggestions; // Add this getter
  bool get isLoading => _isLoading.value;

  void _updateSearchSuggestions() {
    if (query.isEmpty) {
      _searchSuggestions.value = [];
    } else {
      _searchSuggestions.value = _fieldList
          .where((field) =>
              field.spname.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  void selectField(SportFieldRepo field) {
    _selectedListByCategory.value = [field];
  }
}
