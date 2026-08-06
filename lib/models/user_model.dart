class UserModel {
  String uid;
  String name;
  String phone;
  String? profileImage;
  bool isAdmin;
  bool isVerified;
  List<String> favorites;

  UserModel({
    required this.uid,
    required this.name,
    required this.phone,
    this.profileImage,
    this.isAdmin = false,
    this.isVerified = false,
    List<String>? favorites,
  }) : favorites = favorites ?? [];

  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "name": name,
      "phone": phone,
      "profileImage": profileImage,
      "isAdmin": isAdmin,
      "isVerified": isVerified,
      "favorites": favorites,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map["uid"] ?? "",
      name: map["name"] ?? "",
      phone: map["phone"] ?? "",
      profileImage: map["profileImage"],
      isAdmin: map["isAdmin"] ?? false,
      isVerified: map["isVerified"] ?? false,
      favorites: map["favorites"] is List
          ? List<String>.from(map["favorites"])
          : [],
    );
  }

  UserModel copyWith({
    String? name,
    String? phone,
    String? profileImage,
    bool? isAdmin,
    bool? isVerified,
    List<String>? favorites,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      isAdmin: isAdmin ?? this.isAdmin,
      isVerified: isVerified ?? this.isVerified,
      favorites: favorites ?? this.favorites,
    );
  }
}
