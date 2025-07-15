class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String? profilePhoto;
  final String? phoneNumber;
  final String? profilePhotoType;
  final int? roleId;
  final bool? isActive;
  final String? lastLogin;
  final String? socialId;
  final String? socialProvider;
  final String? createdAt;
  final String? updatedAt;
  final String? fcmToken;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePhoto,
    this.phoneNumber,
    this.profilePhotoType,
    this.roleId,
    this.isActive,
    this.lastLogin,
    this.socialId,
    this.socialProvider,
    this.createdAt,
    this.updatedAt,
    this.fcmToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      role: json['Role']?['name'] ?? json['role'] ?? '',
      profilePhoto: json['profile_photo']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
      profilePhotoType: json['profile_photo_type']?.toString(),
      roleId: json['role_id'] is int ? json['role_id'] : int.tryParse(json['role_id']?.toString() ?? ''),
      isActive: json['is_active'] is bool ? json['is_active'] : json['is_active'] == 1,
      lastLogin: json['last_login']?.toString(),
      socialId: json['social_id']?.toString(),
      socialProvider: json['social_provider']?.toString(),
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      fcmToken: json['fcm_token']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'role': role,
      'profile_photo': profilePhoto,
      'phone_number': phoneNumber,
      'profile_photo_type': profilePhotoType,
      'role_id': roleId,
      'is_active': isActive,
      'last_login': lastLogin,
      'social_id': socialId,
      'social_provider': socialProvider,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'fcm_token': fcmToken,
    };
  }
} 