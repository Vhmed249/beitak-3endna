import '../models/property_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/property_card.dart';
import '../utils/constants.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  bool _isLoading = true;
  List<Property> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final provider = Provider.of<AppProvider>(context, listen: false);
    final ids = provider.favorites;
    if (ids.isEmpty) {
      setState(() {
        _favorites = [];
        _isLoading = false;
      });
      return;
    }
    try {
      final properties = await provider.propertyService.getFavorites(ids);
      if (mounted) {
        setState(() {
          _favorites = properties;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading favorites: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المفضلة'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _favorites.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'لا توجد عقارات مفضلة',
                        style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: _favorites.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(property: _favorites[index]);
                  },
                ),
    );
  }
}
