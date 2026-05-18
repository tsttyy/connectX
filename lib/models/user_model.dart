class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final bool isOnline;
  final String status;
  final DateTime lastSeen;
  final String typingTo;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.profileImage,
    this.isOnline = false,
    this.status = "Hey there! I am using ConnectX.",
    required this.lastSeen,
    this.typingTo = "",
  });

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    bool? isOnline,
    String? status,
    DateTime? lastSeen,
    String? typingTo,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      isOnline: isOnline ?? this.isOnline,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      typingTo: typingTo ?? this.typingTo,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'isOnline': isOnline,
      'status': status,
      'lastSeen': lastSeen.toIso8601String(),
      'typingTo': typingTo,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      profileImage: map['profileImage'] ?? '',
      isOnline: map['isOnline'] ?? false,
      status: map['status'] ?? '',
      lastSeen: DateTime.parse(map['lastSeen'] ?? DateTime.now().toIso8601String()),
      typingTo: map['typingTo'] ?? '',
    );
  }
}
