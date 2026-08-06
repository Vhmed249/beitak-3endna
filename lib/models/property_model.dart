import 'package:cloud_firestore/cloud_firestore.dart';

class Property {
  String? id;

  String userId;

  String title;

  String description;

  String address;

  String city;

  String category;

  double price;

  String rentType;

  String? neighborhood;

  double latitude;

  double longitude;

  List<String> imageUrls;

  String phone;

  String whatsapp;

  int rooms;

  double size;

  int floor;

  bool isVerified;

  bool isPremium;
  bool isFeatured = false;
  double? rating;
  int? ratingCount;
  String furnished;
  String status;

  int views;

  int favoritesCount;

  List<Map<String, dynamic>> reviews;

  DateTime createdAt;

  Property({
    this.id,

    required this.userId,

    required this.title,

    required this.description,

    required this.address,

    required this.city,

    required this.category,

    required this.price,

    required this.rentType,

    this.neighborhood,

    required this.latitude,

    required this.longitude,

    required this.imageUrls,

    required this.phone,

    required this.whatsapp,

    this.rooms = 1,

    this.size = 0,

    this.floor = 0,

    this.isVerified = false,

    this.isPremium = false,
    this.isFeatured = false,
    this.rating,
    this.ratingCount,
    this.furnished = 'غير مفروش',
    this.status = 'pending',

    this.views = 0,

    this.favoritesCount = 0,

    this.reviews = const [],

    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get hasImages => imageUrls.isNotEmpty;

  String get mainImage => imageUrls.isNotEmpty ? imageUrls.first : '';

  Map<String, dynamic> toMap() {
    return {
      "userId": userId,

      "title": title,

      "description": description,

      "address": address,

      "city": city,

      "category": category,

      "price": price,

      "rentType": rentType,

      "neighborhood": neighborhood,

      "latitude": latitude,

      "longitude": longitude,

      "imageUrls": imageUrls,

      "phone": phone.replaceAll(RegExp(r"\s+"), ""),

      "whatsapp": whatsapp.replaceAll(RegExp(r"\s+"), ""),

      "rooms": rooms,

      "size": size,

      "floor": floor,

      "isVerified": isVerified,

      "isPremium": isPremium,
      "isFeatured": isFeatured,
      "rating": rating,
      "ratingCount": ratingCount,
      "furnished": furnished,
      "status": status,

      "views": views,

      "favoritesCount": favoritesCount,
      "reviews": reviews,

      "createdAt": Timestamp.fromDate(createdAt),
    };
  }

  factory Property.fromMap(String id, Map<String, dynamic> map) {
    return Property(
      id: id,

      userId: map["userId"] ?? "",

      title: map["title"] ?? "",

      description: map["description"] ?? "",

      address: map["address"] ?? "",

      city: map["city"] ?? "",

      category: map["category"] ?? "",

      price: (map["price"] ?? 0).toDouble(),

      rentType: map["rentType"] ?? "",

      neighborhood: map["neighborhood"],

      latitude: (map["latitude"] ?? 0).toDouble(),

      longitude: (map["longitude"] ?? 0).toDouble(),

      imageUrls: List<String>.from(map["imageUrls"] ?? []),

      phone: map["phone"] ?? "",

      whatsapp: map["whatsapp"] ?? "",

      rooms: map["rooms"] ?? 1,

      size: (map["size"] ?? 0).toDouble(),

      floor: map["floor"] ?? 0,

      isVerified: map["isVerified"] ?? false,

      isPremium: map["isPremium"] ?? false,

      views: map["views"] ?? 0,

      favoritesCount: map["favoritesCount"] ?? 0,

      reviews: map["reviews"] is List
          ? (map["reviews"] as List)
                .where((e) => e is Map)
                .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
                .toList()
          : [],

      isFeatured: map["isFeatured"] ?? false,
      rating: (map["rating"] as num?)?.toDouble(),
      ratingCount: map["ratingCount"] ?? 0,
      furnished: map["furnished"] ?? "غير مفروش",
      status: map["status"] ?? "pending",

      createdAt: map["createdAt"] is Timestamp
          ? (map["createdAt"] as Timestamp).toDate()
          : map["createdAt"] is String
          ? DateTime.tryParse(map["createdAt"]) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Property copyWith({
    String? title,
    String? description,
    double? price,
    String? address,
    String? phone,
    String? whatsapp,
    List<String>? imageUrls,
    String? status,
  }) {
    return Property(
      id: id,
      userId: userId,
      title: title ?? this.title,
      description: description ?? this.description,
      address: address ?? this.address,
      city: city,
      category: category,
      price: price ?? this.price,
      rentType: rentType,
      neighborhood: neighborhood,
      latitude: latitude,
      longitude: longitude,
      imageUrls: imageUrls ?? this.imageUrls,
      phone: phone ?? this.phone,
      whatsapp: whatsapp ?? this.whatsapp,
      rooms: rooms,
      size: size,
      floor: floor,
      isVerified: isVerified,
      isPremium: isPremium,
      isFeatured: isFeatured,
      rating: rating,
      ratingCount: ratingCount,
      furnished: furnished,
      status: status ?? this.status,
      views: views,
      favoritesCount: favoritesCount,
      reviews: reviews,
      createdAt: createdAt,
    );
  }
}
