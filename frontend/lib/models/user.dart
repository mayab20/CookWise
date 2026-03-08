class User {
  final String? id;

  // Identity
  final String? name;
  final String? email;
  final String? password;

  // Required at registration
  final DateTime? birthdate;
  final String? sex;

  // Preferences (onboarding)
  final List<String> allergies;
  final List<String> dietaryPreferences;
  final List<String> favoriteCuisines;
  final List<String> dislikedIngredients;

  // System
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? token;

  const User({
    this.id,
    this.name,
    this.email,
    this.password,
    this.birthdate,
    this.sex,
    this.allergies = const [],
    this.dietaryPreferences = const [],
    this.favoriteCuisines = const [],
    this.dislikedIngredients = const [],
    this.role = 'user',
    this.createdAt,
    this.updatedAt,
    this.token,
  });


  factory User.login({
    required String email,
    required String password,
  }) {
    return User(
      email: email,
      password: password,
    );
  }


  factory User.register({
    required String name,
    required String email,
    required String password,
    required DateTime birthdate,
    required String sex,
  }) {
    return User(
      name: name,
      email: email,
      password: password,
      birthdate: birthdate,
      sex: sex,
    );
  }


  factory User.preferences({
    required String id,
    List<String> allergies = const [],
    List<String> dietaryPreferences = const [],
    List<String> favoriteCuisines = const [],
    List<String> dislikedIngredients = const [],
  }) {
    return User(
      id: id,
      allergies: allergies,
      dietaryPreferences: dietaryPreferences,
      favoriteCuisines: favoriteCuisines,
      dislikedIngredients: dislikedIngredients,
    );
  }

 
  factory User.fromJson(Map<String, dynamic> json, {String? token}) {
    return User(
      id: json['_id'] ?? json['id'], // Handle both _id and id
      name: json['name'],
      email: json['email'],
      birthdate: json['birthdate'] != null
          ? DateTime.parse(json['birthdate'])
          : null,
      sex: json['sex'],
      allergies: List<String>.from(json['allergies'] ?? []),
      dietaryPreferences:
          List<String>.from(json['dietaryPreferences'] ?? []),
      favoriteCuisines:
          List<String>.from(json['favoriteCuisines'] ?? []),
      dislikedIngredients:
          List<String>.from(json['dislikedIngredients'] ?? []),
      role: json['role'] ?? 'user',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      token: token,
    );
  }


  Map<String, dynamic> toLoginJson() {
    return {
      'email': email,
      'password': password,
    };
  }

  Map<String, dynamic> toRegisterJson() {
    return {
      'name': name,
      'email': email,
      'password': password,
      'birthdate': birthdate!.toIso8601String(),
      'sex': sex,
    };
  }

  Map<String, dynamic> toPreferencesJson() {
    return {
      'allergies': allergies,
      'dietaryPreferences': dietaryPreferences,
      'favoriteCuisines': favoriteCuisines,
      'dislikedIngredients': dislikedIngredients,
    };
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'name': name,
      'birthdate': birthdate?.toIso8601String(),
      'sex': sex,
      'allergies': allergies,
      'dietaryPreferences': dietaryPreferences,
      'favoriteCuisines': favoriteCuisines,
      'dislikedIngredients': dislikedIngredients,
    };
  }

  User copyWith({
    String? name,
    DateTime? birthdate,
    String? sex,
    List<String>? allergies,
    List<String>? dietaryPreferences,
    List<String>? favoriteCuisines,
    List<String>? dislikedIngredients,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email,
      password: password,
      birthdate: birthdate ?? this.birthdate,
      sex: sex ?? this.sex,
      allergies: allergies ?? this.allergies,
      dietaryPreferences:
          dietaryPreferences ?? this.dietaryPreferences,
      favoriteCuisines:
          favoriteCuisines ?? this.favoriteCuisines,
      dislikedIngredients:
          dislikedIngredients ?? this.dislikedIngredients,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      token: token,
    );
  }

  bool get isAdmin => role == 'admin';
}
