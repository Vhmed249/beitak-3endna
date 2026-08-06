import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/property_card.dart';
import '../utils/constants.dart';
import '../models/property_model.dart';
import 'add_property_screen.dart';
import 'favorites_screen.dart';
import 'profile_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeTab(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  void _openAddProperty() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى تسجيل الدخول أولاً')));
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddPropertyScreen()),
    ).then((_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textDark.withOpacity(0.6),
        onTap: (index) {
          if (index == 2) {
            _openAddProperty();
            return;
          }
          setState(() => _currentIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'بحث'),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle, color: AppColors.secondary, size: 32),
            label: 'إضافة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'حسابي',
          ),
        ],
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddPropertyScreen(),
                  ),
                ).then((_) => setState(() {}));
              },
              backgroundColor: AppColors.secondary,
              tooltip: 'إضافة عقار',
              child: const Icon(Icons.add, color: AppColors.white),
            )
          : null,
    );
  }
}

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AppProvider>(context, listen: false);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            maxLength: 100,
            decoration: InputDecoration(
              hintText: 'ابحث عن عقار...',
              prefixIcon: const Icon(Icons.search, color: AppColors.primary),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: AppColors.background,
            ),
            onSubmitted: (value) {
              final query = value.trim();

              if (query.isEmpty) return;

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SearchScreen(initialQuery: value),
                ),
              );
            },
          ),
        ),
        Expanded(
          child: StreamBuilder<List<Property>>(
            stream: provider.propertyService.getProperties(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('حدث خطأ: ${snapshot.error}'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => setState(() {}),
                        child: const Text('إعادة المحاولة'),
                      ),
                    ],
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('لا توجد عقارات حالياً. أضف عقارك الأول!'),
                    ],
                  ),
                );
              }
              final properties = snapshot.data!;
              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                  await Future.delayed(const Duration(milliseconds: 500));
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: properties.length,
                  itemBuilder: (context, index) {
                    return PropertyCard(property: properties[index]);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
