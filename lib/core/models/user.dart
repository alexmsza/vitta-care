class AppUser {
  final int id;
  final String name;
  final String email;
  final String role; // 'professional' | 'family'
  final String token;
  final bool isActive;
  final String? phone;
  // Professional-only
  final String? specialty;
  final String? crmCoren;
  final double? rating;
  final double? balance;
  // Family-only
  final String? clinicalSummary;
  final List<String>? hobbies;
  final DateTime? createdAt;

  const AppUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.token,
    required this.isActive,
    this.phone,
    this.specialty,
    this.crmCoren,
    this.rating,
    this.balance,
    this.clinicalSummary,
    this.hobbies,
    this.createdAt,
  });

  /// Parses the POST /auth/login response (Token schema).
  /// Fields: access_token, role, user_id, user_name
  /// Note: email is not in the login response — pass it from the form if needed.
  factory AppUser.fromLoginJson(Map<String, dynamic> json,
      {String email = ''}) {
    return AppUser(
      id: json['user_id'] as int,
      name: json['user_name'] as String,
      email: email,
      role: json['role'] as String,
      token: json['access_token'] as String,
      isActive: true, // if login succeeds, account is active
    );
  }

  /// Parses the GET /profile/me response (UserResponse schema).
  /// Requires the stored token to be passed in.
  factory AppUser.fromProfileJson(Map<String, dynamic> json,
      {required String token}) {
    return AppUser(
      id: json['id'] as int,
      name: json['name'] as String,
      email: json['email'] as String,
      role: json['role'] as String,
      token: token,
      isActive: json['is_active'] as bool? ?? true,
      phone: json['phone'] as String?,
      specialty: json['specialty'] as String?,
      crmCoren: json['crm_coren'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      balance: (json['balance'] as num?)?.toDouble(),
      clinicalSummary: json['clinical_summary'] as String?,
      hobbies: json['hobbies'] != null
          ? List<String>.from(json['hobbies'] as List)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'role': role,
        'token': token,
        'is_active': isActive,
        if (phone != null) 'phone': phone,
        if (specialty != null) 'specialty': specialty,
        if (crmCoren != null) 'crm_coren': crmCoren,
        if (rating != null) 'rating': rating,
        if (balance != null) 'balance': balance,
        if (clinicalSummary != null) 'clinical_summary': clinicalSummary,
        if (hobbies != null) 'hobbies': hobbies,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      };

  AppUser copyWith({
    int? id,
    String? name,
    String? email,
    String? role,
    String? token,
    bool? isActive,
    String? phone,
    String? specialty,
    String? crmCoren,
    double? rating,
    double? balance,
    String? clinicalSummary,
    List<String>? hobbies,
    DateTime? createdAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      role: role ?? this.role,
      token: token ?? this.token,
      isActive: isActive ?? this.isActive,
      phone: phone ?? this.phone,
      specialty: specialty ?? this.specialty,
      crmCoren: crmCoren ?? this.crmCoren,
      rating: rating ?? this.rating,
      balance: balance ?? this.balance,
      clinicalSummary: clinicalSummary ?? this.clinicalSummary,
      hobbies: hobbies ?? this.hobbies,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
