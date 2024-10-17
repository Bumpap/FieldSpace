import 'package:code2/models/demensions.dart';
import 'package:code2/modules/recommended/commentSection.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/recommend_ctrl.dart';

class RecommendedDetailView extends StatelessWidget {
  final String id;

  RecommendedDetailView({required this.id});

  @override
  Widget build(BuildContext context) {
    final RecommendCtrl recommendCtrl = Get.find();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      recommendCtrl.getSportFieldDetails(id);
    });

    return FutureBuilder<Map<String, dynamic>>(
      future: recommendCtrl.getSportFieldDetails(id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Error'),
            ),
            body: Center(child: Text('Error: ${snapshot.error}')),
          );
        } else if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(
              title: Text('Not Found'),
            ),
            body: Center(child: Text('No details available')),
          );
        } else {
          final field = snapshot.data!;
          return Scaffold(
            appBar: AppBar(
              title: Text(field['name'] ?? 'Unknown Field'),
            ),
            body: Column(
              children: [
                Image.network(
                  field['image'] ?? '',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: Demensions.height20 * 10,
                ),
                Padding(
                  padding: EdgeInsets.all(Demensions.radius16 / 2),
                  child: Text(
                    field['name'] ?? 'No Name',
                    style: TextStyle(
                        fontSize: Demensions.font26 - 2,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Demensions.radius16 / 2),
                  child: Text(
                    field['address'] ?? 'No Address',
                    style: TextStyle(fontSize: Demensions.font16),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(Demensions.radius16 / 2),
                  child: Row(
                    children: [
                      Icon(Icons.star, color: Colors.yellow),
                      Text(recommendCtrl
                          .calculateRating(field['rating']?.toInt() ?? 0)
                          .toStringAsFixed(1)),
                    ],
                  ),
                ),
                Expanded(
                  child: CommentSection(sportFieldId: id),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
