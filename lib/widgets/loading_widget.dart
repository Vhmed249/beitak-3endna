import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/constants.dart';

class LoadingWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (ctx, i) => Card(
          margin: EdgeInsets.only(bottom: 12),
          child: Row(
            children: [
              Container(width: 120, height: 120, color: AppColors.white),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, color: AppColors.white),
                      SizedBox(height: 8),
                      Container(height: 12, color: AppColors.white),
                      SizedBox(height: 8),
                      Container(height: 12, width: 80, color: AppColors.white),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
