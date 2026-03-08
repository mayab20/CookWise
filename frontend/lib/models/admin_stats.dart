class AdminStats {
  final int users;
  final int recipes;
  final int items;
  final int pantryItems;

  AdminStats({
    required this.users,
    required this.recipes,
    required this.items,
    required this.pantryItems,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      users: json['users'],
      recipes: json['recipes'],
      items: json['items'] ?? 0,
      pantryItems: json['pantryItems'],
    );
  }
}
