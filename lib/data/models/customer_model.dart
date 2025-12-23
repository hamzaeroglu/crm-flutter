import '../../presentation/domain/entities/customer.dart';

class CustomerModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final CustomerCategory category;
  final bool isFavorite;
  final List<String> notes;
  final List<String> tags;

  CustomerModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.category = CustomerCategory.active,
    this.isFavorite = false,
    this.notes = const [],
    this.tags = const [],
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      category: CustomerCategory.values.firstWhere(
        (e) => e.toString().split('.').last == json['category'],
        orElse: () => CustomerCategory.active,
      ),
      isFavorite: json['isFavorite'] ?? false,
      notes: json['notes'] != null ? List<String>.from(json['notes']) : <String>[],
      tags: json['tags'] != null ? List<String>.from(json['tags']) : <String>[],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'category': category.toString().split('.').last,
      'isFavorite': isFavorite,
      'notes': notes,
      'tags': tags,
    };
  }

  CustomerModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    CustomerCategory? category,
    bool? isFavorite,
    List<String>? notes,
    List<String>? tags,
  }) {
    return CustomerModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      category: category ?? this.category,
      isFavorite: isFavorite ?? this.isFavorite,
      notes: notes ?? this.notes,
      tags: tags ?? this.tags,
    );
  }
} 