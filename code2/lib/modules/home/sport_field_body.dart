import 'package:code2/widgets/app_column.dart';
import 'package:code2/widgets/big_text1.dart';
import 'package:dots_indicator/dots_indicator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../components/sport_field_card.dart';
import '../../controllers/cart_field_ctrl.dart';
import '../../controllers/recommend_ctrl.dart';
import '../../data/repos/recommend_repo.dart';
import '../../models/demensions.dart';
import '../../route/route_view.dart';
import '../../theme.dart';
import '../../widgets/big_text2.dart';
import '../../widgets/small_text1.dart';
import '../../controllers/sport_field_ctrl.dart';

class SportFieldBody extends StatefulWidget {
  const SportFieldBody({super.key});

  @override
  State<SportFieldBody> createState() => _SportFieldBodyState();
}

class _SportFieldBodyState extends State<SportFieldBody> {
  PageController pageController = PageController(viewportFraction: 0.85);

  var _currPageValue = 0.0;
  double _scaleFactor = 0.8;
  double _height = Demensions.pageViewContainer;
  final SportFieldCtrl controller = Get.find();
  final RecommendCtrl recommendCtrl = Get.find();

  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      setState(() {
        _currPageValue = pageController.page!;
      });
    });
    _initializeData();
  }

  Future<void> _initializeData() async {
    Get.put(CartFieldCtrl());
    await controller.fetchData();
    await Future.wait(
      controller.items.map((item) async {
        await recommendCtrl.fetchRating(item.id);
      }).toList(),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: Demensions.pageView,
          child: Obx(() {
            if (controller.items.isEmpty || recommendCtrl.items.isEmpty) {
              return Center(child: CircularProgressIndicator());
            }
            return PageView.builder(
              controller: pageController,
              itemCount: controller.items.length,
              itemBuilder: (context, position) {
                return _buildPageItem(position);
              },
            );
          }),
        ),
        // Dots Indicator
        Obx(() {
          return DotsIndicator(
            dotsCount: controller.items.isEmpty ? 1 : controller.items.length,
            position: _currPageValue,
            decorator: DotsDecorator(
              activeColor: primaryColor500,
              size: Size.square(Demensions.radius16 - 7),
              activeSize:
                  Size(Demensions.radius16 + 2, Demensions.radius16 - 7),
              activeShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(Demensions.height10 / 2),
              ),
            ),
          );
        }),
        // Popular Text
        SizedBox(height: Demensions.height30),
        Container(
          margin: EdgeInsets.only(left: Demensions.width30),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              BigText1(text: "Popular"),
              SizedBox(width: Demensions.width10),
              Container(
                margin: const EdgeInsets.only(bottom: 3),
                child: BigText2(text: "."),
              ),
              SizedBox(width: Demensions.width10),
              Container(
                margin: const EdgeInsets.only(bottom: 2),
                child: SmallText1(text: "sport field pairing"),
              ),
            ],
          ),
        ),
        // List of sport and image
        Obx(() {
          if (controller.items.isEmpty) {
            return Center(child: CircularProgressIndicator());
          }
          return Column(
            children: controller.items
                .asMap()
                .entries
                .map((fieldEntity) => SportFieldCard(
                      field: fieldEntity.value,
                      isSelected: false,
                      onLongPress: (fieldEntity) {},
                    ))
                .toList(),
          );
        }),
      ],
    );
  }

  Widget _buildPageItem(int index) {
    Matrix4 matrix = Matrix4.identity();

    if (index == _currPageValue.floor()) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() + 1) {
      var currScale =
          _scaleFactor + (_currPageValue - index + 1) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else if (index == _currPageValue.floor() - 1) {
      var currScale = 1 - (_currPageValue - index) * (1 - _scaleFactor);
      var currTrans = _height * (1 - currScale) / 2;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, currTrans, 0);
    } else {
      var currScale = 0.8;
      matrix = Matrix4.diagonal3Values(1, currScale, 1)
        ..setTranslationRaw(0, _height * (1 - _scaleFactor) / 2, 1);
    }

    var field = controller.items[index];
    var item = recommendCtrl.items.firstWhere(
      (item) => item.sport_field_id == field.id,
      orElse: () => RecommendRepo(
        id: '',
        rating: 0,
        sport_field_id: '',
        comments: [],
      ),
    );
    double rating = item.rating.toDouble();

    return Transform(
      transform: matrix,
      child: Stack(
        children: [
          GestureDetector(
            onTap: () {
              Get.toNamed(RouteView.getRecomended(field.id));
            },
            child: Container(
              height: Demensions.pageViewContainer,
              margin: EdgeInsets.only(
                  left: Demensions.width10, right: Demensions.width10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Demensions.radius30),
                color: index.isEven ? primaryColor200 : primaryColor400,
                image: DecorationImage(
                  fit: BoxFit.cover,
                  image: NetworkImage(field.image),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: Demensions.pageViewTextContainer,
              margin: EdgeInsets.only(
                  left: Demensions.width20,
                  right: Demensions.width20,
                  bottom: Demensions.height30),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Demensions.radius30),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFFe8e8e8),
                    blurRadius: Demensions.radius20 / 4,
                    offset: Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(-5, 0),
                  ),
                  BoxShadow(
                    color: Colors.white,
                    offset: Offset(5, 0),
                  ),
                ],
              ),
              child: Container(
                padding: EdgeInsets.only(
                    top: Demensions.height15,
                    left: Demensions.width10,
                    right: Demensions.width10),
                child: AppColumn(
                  text: field.spname,
                  rating: recommendCtrl.calculateRating(rating.toInt())
                    ..toStringAsFixed(1),
                  commentCount: recommendCtrl.getCommentCount(field.id),
                  id: field.id,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
