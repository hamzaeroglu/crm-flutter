enum CustomerCategory { active, potential, vip, inactive }

class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final CustomerCategory category;
  final bool isFavorite;
  final List<String> notes;
  final List<String> tags;

  Customer({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.category = CustomerCategory.active,
    this.isFavorite = false,
    this.notes = const [],
    this.tags = const [],
  });
} 