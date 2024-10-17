import 'package:code2/models/demensions.dart';
import 'package:code2/modules/recommended/recommended_detail_view.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:get/get.dart';
import '../../controllers/recommend_ctrl.dart';
import '../../controllers/users_ctrl.dart';
import 'package:code2/widgets/big_text.dart';
import 'package:code2/widgets/small_text.dart';

class RecommendFieldView extends StatelessWidget {
  final RecommendCtrl recommendCtrl = Get.put(RecommendCtrl());
  final UsersCtrl usersCtrl = Get.put(UsersCtrl());

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      recommendCtrl.fetchData();
      recommendCtrl.fetchDataSport();
    });

    return Scaffold(
      appBar: AppBar(
        title: Text('Recommend Sport Field'),
      ),
      body: Obx(() {
        if (usersCtrl.currentUser.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: Demensions.width10 * 10,
                  height: Demensions.height10 * 10,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    image: DecorationImage(
                      fit: BoxFit.fill,
                      image:
                          AssetImage("assets/images/user_profile_example.png"),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                SmallText(text: "Welcome back,"),
                const SizedBox(
                  height: 4,
                ),
                BigText(text: "Please log in"),
              ],
            ),
          );
        } else {
          return SingleChildScrollView(
            child: Column(
              children: [
                if (recommendCtrl.items.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: Demensions.height20 * 10,
                      autoPlay: true,
                      enlargeCenterPage: true,
                    ),
                    items: recommendCtrl.items.map((recommend) {
                      return Builder(
                        builder: (BuildContext context) {
                          return Container(
                            width: MediaQuery.of(context).size.width,
                            margin: EdgeInsets.symmetric(
                                horizontal: Demensions.height10 / 2),
                            decoration: BoxDecoration(
                              color: Colors.amber,
                            ),
                            child: Image.network(
                              recommendCtrl.getSportFieldImage(
                                      recommend.sport_field_id) ??
                                  '',
                              fit: BoxFit.cover,
                            ),
                          );
                        },
                      );
                    }).toList(),
                  ),
                // Search Bar
                Padding(
                  padding: EdgeInsets.all(Demensions.height10 - 2),
                  child: TypeAheadField(
                    textFieldConfiguration: TextFieldConfiguration(
                      decoration: InputDecoration(
                        hintText: 'Search name sport field',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(Demensions.radius16 / 2),
                        ),
                      ),
                    ),
                    suggestionsCallback: (pattern) async {
                      return recommendCtrl.getSuggestions(pattern);
                    },
                    itemBuilder: (context, suggestion) {
                      return ListTile(
                        title: Text(suggestion),
                      );
                    },
                    onSuggestionSelected: (suggestion) async {
                      String? sportFieldId =
                          recommendCtrl.getSportFieldIdByName(suggestion);
                      if (sportFieldId != null) {
                        await recommendCtrl
                            .handleSuggestionSelected(sportFieldId);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                RecommendedDetailView(id: sportFieldId),
                          ),
                        );
                      }
                    },
                  ),
                ),
                ...recommendCtrl.items.map((recommend) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecommendedDetailView(
                              id: recommend.sport_field_id),
                        ),
                      );
                    },
                    child: Card(
                      margin: EdgeInsets.all(Demensions.radius16 / 2),
                      child: ListTile(
                        leading: Image.network(
                          recommendCtrl.getSportFieldImage(
                                  recommend.sport_field_id) ??
                              '',
                          fit: BoxFit.cover,
                          width: Demensions.width10 * 5,
                          height: Demensions.height10 * 5,
                        ),
                        title: Text(recommendCtrl
                                .getSportFieldName(recommend.sport_field_id) ??
                            ''),
                        subtitle: Text(recommendCtrl.getSportFieldAddress(
                                recommend.sport_field_id) ??
                            ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.yellow),
                            Text(recommendCtrl
                                .calculateRating(recommend.rating.toInt())
                                .toStringAsFixed(1)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
        }
      }),
    );
  }
}
