import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';
import '../widgets/property_card.dart';
import '../utils/constants.dart';
import '../models/property_model.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  const SearchScreen({super.key, this.initialQuery});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _queryController = TextEditingController();
  List<Property> _results = [];
  bool _isSearching = false;

  // فلاتر البحث
  String? _selectedState;
  String? _selectedCity;
  String? _selectedNeighborhood;
  double? _minPrice;
  double? _maxPrice;
  int? _minRooms;
  int? _maxRooms;
  double? _minSize;
  double? _maxSize;
  String? _furnished;
  String? _sortBy;
  bool _showFilters = false;

  Timer? _searchTimer;
  StreamSubscription? _searchSubscription;

  @override
  void initState() {
    super.initState();
    if (widget.initialQuery != null) {
      _queryController.text = widget.initialQuery!;
      _performSearch();
    }
  }

  void _performSearch() {
    setState(() => _isSearching = true);
    final provider = Provider.of<AppProvider>(context, listen: false);

    final stream = provider.propertyService.searchProperties(
      city: _selectedCity,
      minPrice: _minPrice,
      maxPrice: _maxPrice,
      minRooms: _minRooms,
      maxRooms: _maxRooms,
      minSize: _minSize,
      maxSize: _maxSize,
      furnished: _furnished,
      sortBy: _sortBy,
    );

    _searchSubscription?.cancel();

    _searchSubscription = stream.listen((properties) {
      String query = _queryController.text.trim().toLowerCase();
      List<Property> filtered = properties;

      if (query.isNotEmpty) {
        filtered = filtered
            .where(
              (p) =>
                  p.title.toLowerCase().contains(query) ||
                  p.description.toLowerCase().contains(query) ||
                  p.address.toLowerCase().contains(query) ||
                  (p.city.toLowerCase().contains(query)) ||
                  (p.category.toLowerCase().contains(query)),
            )
            .toList();
      }

      // فلتر الحي بشكل صحيح
      if (_selectedNeighborhood != null && _selectedNeighborhood!.isNotEmpty) {
        filtered = filtered
            .where(
              (p) =>
                  (p.neighborhood ?? '').contains(_selectedNeighborhood!) ||
                  p.address.contains(_selectedNeighborhood!),
            )
            .toList();
      }

      if (!mounted) return;

      setState(() {
        _results = filtered;
        _isSearching = false;
      });
    });
  }

  @override
  void dispose() {
    _searchTimer?.cancel();
    _searchSubscription?.cancel();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> states = AppConstants.states;
    final List<String> cities = _selectedState != null
        ? List<String>.from(AppConstants.getCities(_selectedState!))
        : <String>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث متقدم'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _queryController.clear();
              _selectedState = null;
              _selectedCity = null;
              _selectedNeighborhood = null;
              _minPrice = null;
              _maxPrice = null;
              _minRooms = null;
              _maxRooms = null;
              _minSize = null;
              _maxSize = null;
              _furnished = null;
              _sortBy = null;
              _performSearch();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // شريط البحث
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _queryController,
              maxLength: 100,
              decoration: InputDecoration(
                hintText: 'ابحث عن عقار...',
                prefixIcon: const Icon(Icons.search, color: AppColors.primary),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _queryController.clear();
                    _performSearch();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: AppColors.background,
              ),
              onChanged: (value) {
                _searchTimer?.cancel();

                _searchTimer = Timer(const Duration(milliseconds: 500), () {
                  _performSearch();
                });
              },
              onSubmitted: (value) => _performSearch(),
            ),
          ),
          // فلاتر متقدمة
          if (_showFilters)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                children: [
                  // الولاية والمدينة
                  Row(
                    children: [
                      Expanded(child: _buildStateDropdown(states)),
                      const SizedBox(width: 10),
                      Expanded(child: _buildCityDropdown(cities)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // الحي
                  Row(children: [Expanded(child: _buildNeighborhoodDropdown())]),
                  const SizedBox(height: 10),
                  // السعر
                  Row(children: [Expanded(child: _buildPriceRange())]),
                  const SizedBox(height: 10),
                  // الغرف والمساحة
                  Row(
                    children: [
                      Expanded(child: _buildRoomsFilter()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSizeFilter()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // المفروشات والترتيب
                  Row(
                    children: [
                      Expanded(child: _buildFurnishedFilter()),
                      const SizedBox(width: 10),
                      Expanded(child: _buildSortBy()),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                    ),
                    onPressed: _performSearch,
                    child: const Text('تطبيق الفلاتر'),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 10),
          // النتائج
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : _results.isEmpty
                    ? const Center(child: Text('لا توجد نتائج'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _results.length,
                        itemBuilder: (context, index) {
                          return PropertyCard(property: _results[index]);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateDropdown(List<String> states) {
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(
        labelText: 'الولاية',
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      value: _selectedState,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
        ...states.map(
          (s) => DropdownMenuItem<String?>(value: s, child: Text(s)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedState = value;
          _selectedCity = null;
          _selectedNeighborhood = null;
        });
        _performSearch();
      },
    );
  }

  Widget _buildCityDropdown(List<String> cities) {
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(
        labelText: 'المدينة',
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      value: _selectedCity,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
        ...cities.map(
          (c) => DropdownMenuItem<String?>(value: c, child: Text(c)),
        ),
      ],
      onChanged: (value) {
        setState(() {
          _selectedCity = value;
          _selectedNeighborhood = null;
        });
        _performSearch();
      },
    );
  }

  Widget _buildNeighborhoodDropdown() {
    final List<String> neighborhoods = (_selectedState != null && _selectedCity != null)
        ? List<String>.from(
            AppConstants.getNeighborhoods(_selectedState!, _selectedCity!),
          )
        : [];
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(
        labelText: 'الحي',
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      value: _selectedNeighborhood,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
        ...neighborhoods.map(
          (n) => DropdownMenuItem<String?>(value: n, child: Text(n)),
        ),
      ],
      onChanged: (value) {
        setState(() => _selectedNeighborhood = value);
        _performSearch();
      },
    );
  }

  Widget _buildPriceRange() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'الحد الأدنى'),
            keyboardType: TextInputType.number,
            maxLength: 10,
            onChanged: (value) {
              _minPrice = double.tryParse(value);
              _performSearch();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'الحد الأقصى'),
            keyboardType: TextInputType.number,
            maxLength: 10,
            onChanged: (value) {
              _maxPrice = double.tryParse(value);
              _performSearch();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRoomsFilter() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'أقل غرف'),
            keyboardType: TextInputType.number,
            maxLength: 2,
            onChanged: (value) {
              _minRooms = int.tryParse(value);
              _performSearch();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'أكثر غرف'),
            keyboardType: TextInputType.number,
            maxLength: 2,
            onChanged: (value) {
              _maxRooms = int.tryParse(value);
              _performSearch();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSizeFilter() {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'أقل مساحة'),
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) {
              _minSize = double.tryParse(value);
              _performSearch();
            },
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            decoration: const InputDecoration(labelText: 'أكثر مساحة'),
            keyboardType: TextInputType.number,
            maxLength: 6,
            onChanged: (value) {
              _maxSize = double.tryParse(value);
              _performSearch();
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFurnishedFilter() {
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(
        labelText: 'المفروشات',
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      value: _furnished,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('الكل')),
        const DropdownMenuItem<String?>(value: 'مفروش', child: Text('مفروش')),
        const DropdownMenuItem<String?>(
          value: 'غير مفروش',
          child: Text('غير مفروش'),
        ),
        const DropdownMenuItem<String?>(
          value: 'نصف مفروش',
          child: Text('نصف مفروش'),
        ),
      ],
      onChanged: (value) {
        setState(() => _furnished = value);
        _performSearch();
      },
    );
  }

  Widget _buildSortBy() {
    return DropdownButtonFormField<String?>(
      decoration: const InputDecoration(
        labelText: 'ترتيب حسب',
        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
      ),
      value: _sortBy,
      items: [
        const DropdownMenuItem<String?>(value: null, child: Text('الأحدث')),
        const DropdownMenuItem<String?>(
          value: 'price_asc',
          child: Text('الأرخص'),
        ),
        const DropdownMenuItem<String?>(
          value: 'price_desc',
          child: Text('الأغلى'),
        ),
        const DropdownMenuItem<String?>(
          value: 'views',
          child: Text('الأكثر مشاهدة'),
        ),
      ],
      onChanged: (value) {
        setState(() => _sortBy = value);
        _performSearch();
      },
    );
  }
}
