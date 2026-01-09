import 'package:flutter/material.dart';
import '../../data/models/customer_model.dart';
import '../../data/repo/customer_repository.dart';
import '../../presentation/domain/entities/customer.dart';
import '../../core/services/audit_service.dart';

enum SortOption { nameAsc, nameDesc }

class CustomerProvider extends ChangeNotifier {
  final CustomerRepository repository;
  final AuditService _auditService = AuditService();

  List<CustomerModel> _customers = [];
  List<CustomerModel> get customers => _customers;

  List<Customer> get customerEntities => _customers.map(_mapToEntity).toList();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;
  set searchQuery(String value) {
    _searchQuery = value;
    notifyListeners();
  }

  CustomerCategory? _selectedCategory;
  CustomerCategory? get selectedCategory => _selectedCategory;
  set selectedCategory(CustomerCategory? value) {
    _selectedCategory = value;
    notifyListeners();
  }

  bool _showOnlyFavorites = false;
  bool get showOnlyFavorites => _showOnlyFavorites;
  set showOnlyFavorites(bool value) {
    _showOnlyFavorites = value;
    notifyListeners();
  }

  String _selectedTag = '';
  String get selectedTag => _selectedTag;
  set selectedTag(String value) {
    _selectedTag = value;
    notifyListeners();
  }

  List<String> get allTags {
    final allTags = <String>{};
    for (final customer in _customers) {
      if (customer.tags != null) {
        allTags.addAll(customer.tags);
      }
    }
    return allTags.toList()..sort();
  }

  List<Customer> get filteredCustomers {
    final filtered = _customers.where((customer) {
      // Search query filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        final matchesName = customer.name.toLowerCase().contains(query);
        final matchesEmail = customer.email.toLowerCase().contains(query);
        final matchesPhone = customer.phone.toLowerCase().contains(query);
        final matchesNotes = customer.notes != null && 
            customer.notes.any((note) => note.toLowerCase().contains(query));
        final matchesTags = customer.tags != null && 
            customer.tags.any((tag) => tag.toLowerCase().contains(query));
        
        if (!matchesName && !matchesEmail && !matchesPhone && !matchesNotes && !matchesTags) {
          return false;
        }
      }

      // Category filter
      if (_selectedCategory != null && customer.category != _selectedCategory) {
        return false;
      }

      // Favorite filter
      if (_showOnlyFavorites && !customer.isFavorite) {
        return false;
      }

      // Tag filter
      if (_selectedTag.isNotEmpty && (customer.tags == null || !customer.tags.contains(_selectedTag))) {
        return false;
      }

      return true;
    }).toList();

    final entities = filtered.map(_mapToEntity).toList();

    entities.sort((a, b) {
      final aName = a.name.toLowerCase();
      final bName = b.name.toLowerCase();
      switch (_sortOption) {
        case SortOption.nameAsc:
          return aName.compareTo(bName);
        case SortOption.nameDesc:
          return bName.compareTo(aName);
      }
    });

    return entities;
  }

  CustomerProvider(this.repository);

  // Sort option
  SortOption _sortOption = SortOption.nameAsc;
  SortOption get sortOption => _sortOption;
  set sortOption(SortOption value) {
    _sortOption = value;
    notifyListeners();
  }

  void resetFilters() {
    _searchQuery = '';
    _selectedCategory = null;
    _showOnlyFavorites = false;
    _selectedTag = '';
    notifyListeners();
  }

  Customer? findById(String id) {
    final model = _customers.where((c) => c.id == id);
    if (model.isEmpty) return null;
    return _mapToEntity(model.first);
  }

  Customer _mapToEntity(CustomerModel model) {
    return Customer(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      category: model.category,
      isFavorite: model.isFavorite,
      notes: model.notes,
      tags: model.tags,
    );
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();
    _customers = await repository.getCustomers();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(CustomerModel customer) async {
    try {
      await repository.addCustomer(customer);
      await _auditService.logAction(action: 'CREATE_CUSTOMER', details: 'Name: ${customer.name}, Email: ${customer.email}');
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri eklenemedi: $e');
    }
  }

  Future<void> updateCustomer(CustomerModel customer) async {
    try {
      await repository.updateCustomer(customer);
      await _auditService.logAction(action: 'UPDATE_CUSTOMER', details: 'Customer: ${customer.name} (${customer.email})');
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri güncellenemedi: $e');
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      final customer = findById(id);
      final name = customer?.name ?? 'Unknown';
      await repository.deleteCustomer(id);
      await _auditService.logAction(action: 'DELETE_CUSTOMER', details: 'Customer: $name (ID: $id)');
      await fetchCustomers();
    } catch (e) {
      throw Exception('Müşteri silinemedi: $e');
    }
  }

  Future<void> toggleFavorite(String id) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedCustomer = customer.copyWith(isFavorite: !customer.isFavorite);
        await repository.updateCustomer(updatedCustomer);
        final statusStr = updatedCustomer.isFavorite ? 'favorilere eklendi' : 'favorilerden çıkarıldı';
        await _auditService.logAction(
          action: 'TOGGLE_FAVORITE',
          details: 'Müşteri "${customer.name}" $statusStr',
        );
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Favori durumu güncellenemedi: $e');
    }
  }

  Future<void> updateCustomerCategory(String id, CustomerCategory category) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == id);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final oldCategoryName = _getCategoryName(customer.category);
        final newCategoryName = _getCategoryName(category);
        final updatedCustomer = customer.copyWith(category: category);
        await repository.updateCustomer(updatedCustomer);
        await _auditService.logAction(
          action: 'UPDATE_CATEGORY',
          details: 'Müşteri "${customer.name}" segmenti değiştirildi: $oldCategoryName -> $newCategoryName',
        );
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Kategori güncellenemedi: $e');
    }
  }

  String _getCategoryName(CustomerCategory category) {
    switch (category) {
      case CustomerCategory.active: return 'Aktif';
      case CustomerCategory.potential: return 'Potansiyel';
      case CustomerCategory.vip: return 'VIP';
      case CustomerCategory.inactive: return 'Pasif';
    }
  }

  Future<void> addNote(String customerId, String note) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = [...customer.notes, note];
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await _auditService.logAction(
          action: 'ADD_NOTE',
          details: 'Müşteri "${customer.name}" için yeni not eklendi',
        );
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not eklenemedi: $e');
    }
  }

  Future<void> removeNote(String customerId, int noteIndex) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedNotes = List<String>.from(customer.notes);
        updatedNotes.removeAt(noteIndex);
        final updatedCustomer = customer.copyWith(notes: updatedNotes);
        await repository.updateCustomer(updatedCustomer);
        await _auditService.logAction(
          action: 'REMOVE_NOTE',
          details: 'Müşteri "${customer.name}" için bir not silindi',
        );
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Not silinemedi: $e');
    }
  }

  Future<void> addTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        if (!customer.tags.contains(tag)) {
          final updatedTags = [...customer.tags, tag];
          final updatedCustomer = customer.copyWith(tags: updatedTags);
          await repository.updateCustomer(updatedCustomer);
          await _auditService.logAction(
            action: 'ADD_TAG',
            details: 'Müşteri "${customer.name}" için etiket eklendi: $tag',
          );
          await fetchCustomers();
        }
      }
    } catch (e) {
      throw Exception('Etiket eklenemedi: $e');
    }
  }

  Future<void> removeTag(String customerId, String tag) async {
    try {
      final customerIndex = _customers.indexWhere((c) => c.id == customerId);
      if (customerIndex != -1) {
        final customer = _customers[customerIndex];
        final updatedTags = List<String>.from(customer.tags);
        updatedTags.remove(tag);
        final updatedCustomer = customer.copyWith(tags: updatedTags);
        await repository.updateCustomer(updatedCustomer);
        await _auditService.logAction(
          action: 'REMOVE_TAG',
          details: 'Müşteri "${customer.name}" etiket listesinden çıkarıldı: $tag',
        );
        await fetchCustomers();
      }
    } catch (e) {
      throw Exception('Etiket silinemedi: $e');
    }
  }
} 