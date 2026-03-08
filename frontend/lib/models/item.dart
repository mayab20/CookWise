class Item {
  final String id; // MongoDB ObjectId as string
  final String name;
  final String category; // from ITEM_CATEGORY
  final List<String> units; // Array of allowed units
  final DateTime createdAt;
  final DateTime updatedAt;

  Item({
    required this.id,
    required this.name,
    this.category = 'other',
    this.units = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  Item.create({
    required this.name,
    this.category = 'other',
    this.units = const [],
  }) : id = '',
       createdAt = DateTime.now(),
       updatedAt = DateTime.now();

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? 'other',
      units: List<String>.from(json['units'] ?? []),
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'category': category,
      'units': units,
    };
  }
}
