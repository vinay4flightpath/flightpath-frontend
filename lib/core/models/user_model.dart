class AuthenticatedUser {
  final String id;
  final String personId;
  final String email;
  final String flightpathId;
  final String firstName;
  final String lastName;
  final bool isSuperAdmin;

  AuthenticatedUser({
    required this.id,
    required this.personId,
    required this.email,
    required this.flightpathId,
    required this.firstName,
    required this.lastName,
    required this.isSuperAdmin,
  });

  String get fullName => '$firstName $lastName'.trim();

  factory AuthenticatedUser.fromJson(Map<String, dynamic> json) {
    return AuthenticatedUser(
      id: json['id'] as String,
      personId: json['personId'] as String,
      email: json['email'] as String,
      flightpathId: json['flightpathId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      isSuperAdmin: json['isSuperAdmin'] as bool? ?? false,
    );
  }
}

class UserTenantMembership {
  final String membershipId;
  final String tenantId;
  final String tenantName;
  final String tenantCode;
  final String status;
  final List<String> roles;

  UserTenantMembership({
    required this.membershipId,
    required this.tenantId,
    required this.tenantName,
    required this.tenantCode,
    required this.status,
    required this.roles,
  });

  bool get isAdmin => roles.contains('ADMIN');
  bool get isInstructor => roles.contains('INSTRUCTOR');
  bool get isStudent => roles.contains('STUDENT');

  factory UserTenantMembership.fromJson(Map<String, dynamic> json) {
    return UserTenantMembership(
      membershipId: json['membershipId'] as String? ?? json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? json['id'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? json['name'] as String? ?? '',
      tenantCode: json['tenantCode'] as String? ?? json['code'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
