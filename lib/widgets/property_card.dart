import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/property_model.dart';
import '../providers/app_provider.dart';
import '../utils/constants.dart';
import '../screens/property_detail_screen.dart';

class PropertyCard extends StatelessWidget {
  final Property property;

  const PropertyCard({super.key, required this.property});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PropertyDetailScreen(property: property),
            ),
          );
        },
        child: Consumer<AppProvider>(
          builder: (context, provider, _) {
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              elevation: 2,
              child: Stack(
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(15),
                          bottomLeft: Radius.circular(15),
                        ),
                        child: property.imageUrls.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: property.imageUrls.first,
                                width: 120,
                                height: 120,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 120,
                                height: 120,
                                color: AppColors.background,
                                child: const Icon(Icons.home),
                              ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                property.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(property.city),
                              Text('${property.price} ج.س'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  Positioned(
                    top: 5,
                    right: 5,
                    child: IconButton(
                      icon: Icon(
                        provider.isFavorite(property.id ?? '')
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: () {
                        if (property.id != null) {
                          provider.toggleFavorite(property.id!);
                        }
                      },
                    ),
                  ),

                  if (property.isPremium)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(Icons.star, color: Colors.amber),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
