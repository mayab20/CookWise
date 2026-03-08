import 'item.dart';

class RecipeIngredient {
  final Item item;
  final double amount;
  final String unit;

  RecipeIngredient({required this.item, required this.amount, required this.unit});

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    // Handle different possible JSON structures
    Item item;
    if (json['itemId'] != null && json['itemId'] is Map<String, dynamic>) {
      // itemId is populated with full item object
      item = Item.fromJson(json['itemId']);
    } else if (json['item'] != null && json['item'] is Map<String, dynamic>) {
      // item field contains the item object
      item = Item.fromJson(json['item']);
    } else if (json['name'] != null) {
      // ingredient has name directly
      item = Item(
        id: json['_id'] ?? '',
        name: json['name'] ?? 'Unknown Item',
        category: json['category'] ?? 'other',
        units: List<String>.from(json['units'] ?? ['pcs']),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    } else {
      // fallback
      item = Item(
        id: '',
        name: 'Unknown Item',
        category: 'other',
        units: ['pcs'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
    }
    
    return RecipeIngredient(
      item: item,
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit']?.toString() ?? 'pcs',
    );
  }

  Map<String, dynamic> toJson() => {
    'itemId': item.id.isNotEmpty ? item.id : null,
    'amount': amount,
    'unit': unit,
  };
}

class Recipe {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final List<RecipeIngredient> ingredients;
  final List<String> steps;
  final int readyInMinutes;
  final int? servings;
  final String category;
  final String cuisine;
  final List<String> tags;

  Recipe({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.readyInMinutes,
    this.servings,
    required this.category,
    required this.cuisine,
    this.tags = const [],
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json['_id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'],
    imageUrl: json['imageUrl'],
    ingredients: (json['ingredients'] as List<dynamic>?)
        ?.map((i) => i != null ? RecipeIngredient.fromJson(i) : null)
        .where((ingredient) => ingredient != null)
        .cast<RecipeIngredient>()
        .toList() ?? [],
    steps: List<String>.from(json['steps'] ?? []),
    readyInMinutes: json['readyInMinutes'] ?? 0,
    servings: json['servings'],
    category: json['category'] ?? 'Other',
    cuisine: json['cuisine'] ?? 'Other',
    tags: List<String>.from(json['tags'] ?? []),
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'title': title,
    'description': description,
    'imageUrl': imageUrl,
    'ingredients': ingredients
        .where((i) => i.item.id.isNotEmpty) // filter out ingredients with empty item IDs
        .map((i) => i.toJson())
        .toList(),
    'steps': steps,
    'readyInMinutes': readyInMinutes,
    'servings': servings,
    'category': category,
    'cuisine': cuisine,
    'tags': tags,
  };
}
