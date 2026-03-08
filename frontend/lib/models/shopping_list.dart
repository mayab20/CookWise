class ShoppingListItem {
  final String id;
  final String userId;
  final String itemId;
  final double quantity;
  final String unit;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get itemName => _itemName ?? 'Unknown Item';
  String get itemCategory => _itemCategory ?? 'other';
  
  final String? _itemName;
  final String? _itemCategory;

  ShoppingListItem({
    required this.id,
    required this.userId,
    required this.itemId,
    required this.quantity,
    required this.unit,
    this.isCompleted = false,
    required this.createdAt,
    required this.updatedAt,
    String? itemName,
    String? itemCategory,
  }) : _itemName = itemName, _itemCategory = itemCategory;

  factory ShoppingListItem.fromJson(Map<String, dynamic> json) {
    return ShoppingListItem(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      itemId: json['itemId'] is Map ? json['itemId']['_id'] ?? json['itemId']['id'] : json['itemId'] ?? '',
      quantity: (json['quantity'] ?? 0).toDouble(),
      unit: json['unit'] ?? 'pcs',
      isCompleted: json['isCompleted'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
      itemName: json['itemId'] is Map ? json['itemId']['name'] : null,
      itemCategory: json['itemId'] is Map ? json['itemId']['category'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'itemId': itemId,
      'quantity': quantity,
      'unit': unit,
      'isCompleted': isCompleted,
    };
  }
}