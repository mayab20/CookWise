class Nutrition {
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;

  Nutrition({
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
  });

  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      calories: (json['calories'] as num?)?.toDouble(),
      protein: (json['protein'] as num?)?.toDouble(),
      carbs: (json['carbs'] as num?)?.toDouble(),
      fat: (json['fat'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
    };
  }
}

class PantryItem {
  final String id; 
  final String userId;
  final dynamic itemId;
  final double quantity;
  final String unit;
  final DateTime? expirationDate;
  final String? imageUrl;
  final Nutrition? nutrition;
  final DateTime createdAt;
  final DateTime updatedAt;

  PantryItem({
    required this.id,
    required this.userId,
    required this.itemId,
    this.quantity = 0,
    this.unit = 'pcs',
    this.expirationDate,
    this.imageUrl,
    this.nutrition,
    required this.createdAt,
    required this.updatedAt,
  });

  String get itemName {
    if (itemId is Map) {
      return itemId['name'] ?? 'Unknown Item';
    }
    return itemId.toString();
  }

  String get itemIdString {
    if (itemId is Map) {
      return itemId['_id'] ?? itemId['id'] ?? '';
    }
    return itemId.toString();
  }

  String get itemCategory {
    if (itemId is Map) {
      return itemId['category'] ?? 'other';
    }
    return 'other';
  }

  factory PantryItem.fromJson(Map<String, dynamic> json) {
    return PantryItem(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] ?? 'pcs',
      expirationDate: json['expirationDate'] != null
          ? DateTime.parse(json['expirationDate'])
          : null,
      imageUrl: json['imageUrl'],
      nutrition: json['nutrition'] != null
          ? Nutrition.fromJson(json['nutrition'])
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'itemId': itemIdString, // Use the string ID for API calls
      'quantity': quantity,
      'unit': unit,
      'userId': userId, // Always include userId as it's required
    };
    
    // Only include optional fields if they have values
    if (id.isNotEmpty) json['_id'] = id;
    if (expirationDate != null) json['expirationDate'] = expirationDate!.toIso8601String();
    if (imageUrl != null) json['imageUrl'] = imageUrl;
    if (nutrition != null) json['nutrition'] = nutrition!.toJson();
    
    return json;
  }
}
