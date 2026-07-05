enum UserRole { user, bengkel }

class AppUser {
  final String uid;
  final String email;
  final String displayName;
  final UserRole activeRole;
  final String? bengkelId;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.activeRole,
    this.bengkelId,
  });

  AppUser copyWith({UserRole? activeRole, String? bengkelId}) => AppUser(
    uid: uid,
    email: email,
    displayName: displayName,
    activeRole: activeRole ?? this.activeRole,
    bengkelId: bengkelId ?? this.bengkelId,
  );

  Map<String, dynamic> toJson() => {
    'email': email,
    'displayName': displayName,
    'activeRole': activeRole.name,
    'bengkelId': bengkelId,
  };

  factory AppUser.fromJson(String uid, Map<String, dynamic> json) => AppUser(
    uid: uid,
    email: json['email'] as String,
    displayName: json['displayName'] as String,
    activeRole: UserRole.values.byName(json['activeRole'] as String),
    bengkelId: json['bengkelId'] as String?,
  );
}
