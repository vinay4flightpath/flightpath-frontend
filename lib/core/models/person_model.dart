class Person {
  final String id;
  final String flightpathId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String status;
  final DateTime createdAt;
  final bool hasUserAccount;
  final String? inviteToken;
  final List<PersonTenantRole> memberships;

  Person({
    required this.id,
    required this.flightpathId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.status,
    required this.createdAt,
    this.hasUserAccount = false,
    this.inviteToken,
    this.memberships = const [],
  });

  String get fullName => '$firstName $lastName'.trim();

  factory Person.fromJson(Map<String, dynamic> json) {
    final membershipsList = (json['memberships'] as List<dynamic>?)
            ?.map((m) => PersonTenantRole.fromJson(m as Map<String, dynamic>))
            .toList() ??
        [];

    final userAccount = json['userAccount'] as Map<String, dynamic>?;

    return Person(
      id: json['id'] as String,
      flightpathId: json['flightpathId'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      hasUserAccount: userAccount != null,
      inviteToken: userAccount?['inviteToken'] as String?,
      memberships: membershipsList,
    );
  }
}

class PersonTenantRole {
  final String tenantId;
  final String tenantName;
  final String tenantCode;
  final List<String> roles;

  PersonTenantRole({
    required this.tenantId,
    required this.tenantName,
    required this.tenantCode,
    required this.roles,
  });

  factory PersonTenantRole.fromJson(Map<String, dynamic> json) {
    return PersonTenantRole(
      tenantId: json['tenantId'] as String? ?? '',
      tenantName: json['tenantName'] as String? ?? '',
      tenantCode: json['tenantCode'] as String? ?? '',
      roles: (json['roles'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
    );
  }
}
