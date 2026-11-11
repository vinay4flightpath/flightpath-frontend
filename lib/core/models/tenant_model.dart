class Tenant {
  final String id;
  final String name;
  final String code;
  final String status;
  final int totalMembers;
  final int adminCount;
  final int instructorCount;
  final int studentCount;
  final DateTime createdAt;

  Tenant({
    required this.id,
    required this.name,
    required this.code,
    required this.status,
    this.totalMembers = 0,
    this.adminCount = 0,
    this.instructorCount = 0,
    this.studentCount = 0,
    required this.createdAt,
  });

  factory Tenant.fromJson(Map<String, dynamic> json) {
    return Tenant(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      status: json['status'] as String? ?? 'ACTIVE',
      totalMembers: json['totalMembers'] as int? ?? 0,
      adminCount: json['adminCount'] as int? ?? 0,
      instructorCount: json['instructorCount'] as int? ?? 0,
      studentCount: json['studentCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}

class TenantMember {
  final String membershipId;
  final String tenantId;
  final String status;
  final DateTime joinedAt;
  final List<String> roles;
  final String personId;
  final String flightpathId;
  final String firstName;
  final String lastName;
  final String email;
  final String? phone;
  final String personStatus;

  TenantMember({
    required this.membershipId,
    required this.tenantId,
    required this.status,
    required this.joinedAt,
    required this.roles,
    required this.personId,
    required this.flightpathId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.personStatus,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isAdmin => roles.contains('ADMIN');
  bool get isInstructor => roles.contains('INSTRUCTOR');
  bool get isStudent => roles.contains('STUDENT');

  factory TenantMember.fromJson(Map<String, dynamic> json) {
    final person = json['person'] as Map<String, dynamic>? ?? {};
    final rolesList = (json['roles'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];

    return TenantMember(
      membershipId: json['membershipId'] as String? ?? json['id'] as String? ?? '',
      tenantId: json['tenantId'] as String? ?? '',
      status: json['status'] as String? ?? 'ACTIVE',
      joinedAt: json['joinedAt'] != null
          ? DateTime.tryParse(json['joinedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      roles: rolesList,
      personId: person['id'] as String? ?? '',
      flightpathId: person['flightpathId'] as String? ?? '',
      firstName: person['firstName'] as String? ?? '',
      lastName: person['lastName'] as String? ?? '',
      email: person['email'] as String? ?? '',
      phone: person['phone'] as String?,
      personStatus: person['status'] as String? ?? 'ACTIVE',
    );
  }
}
