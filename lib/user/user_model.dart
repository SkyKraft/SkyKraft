class UserModel {
  final String uid;
  final String name;
  final String email;
  final String accountType;
  final String? photoUrl;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.accountType,
    this.photoUrl,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      accountType: map['accountType'] ?? '',
      photoUrl: map['photoUrl']?.toString(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'accountType': accountType,
      'photoUrl': photoUrl,
    };
  }
} 