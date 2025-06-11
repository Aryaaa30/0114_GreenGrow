class UserModel {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final String role;
  final String? profilePhoto;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.role,
    this.profilePhoto,
    this.phoneNumber,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      role: json['role'],
      profilePhoto: json['profile_photo']?.toString(),
      phoneNumber: json['phone_number']?.toString(),
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
    };
  }
} 