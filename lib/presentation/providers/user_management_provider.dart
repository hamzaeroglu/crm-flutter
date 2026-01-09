import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/services/user_service.dart';
import '../../core/services/audit_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuditService _auditService = AuditService();

  List<Map<String, dynamic>> _users = [];
  String _searchQuery = '';

  List<Map<String, dynamic>> get users {
    if (_searchQuery.isEmpty) return _users;
    return _users.where((user) {
      final name = (user['name'] as String? ?? '').toLowerCase();
      final email = (user['email'] as String? ?? '').toLowerCase();
      final query = _searchQuery.toLowerCase();
      return name.contains(query) || email.contains(query);
    }).toList();
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  StreamSubscription? _userSubscription;

  void listenToUsers() {
    _isLoading = true;
    notifyListeners();

    _userSubscription?.cancel();
    _userSubscription = _userService.getUsersStream().listen((users) {
      _users = users;
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      _isLoading = false;
      notifyListeners();
      // Error handling strategy can be improved here
      print('User stream error: $error');
    });
  }

  @override
  void dispose() {
    _userSubscription?.cancel();
    super.dispose();
  }

  Future<void> updateUserRole(String uid, String email, String oldRole, String newRole) async {
    try {
      await _userService.updateUserRole(uid, newRole);
      
      // Audit Log
      await _auditService.logAction(
        action: 'CHANGE_ROLE',
        details: 'User $email role changed from $oldRole to $newRole',
      );

      // Listeyi güncelle
      final index = _users.indexWhere((u) => u['uid'] == uid);
      if (index != -1) {
        _users[index]['role'] = newRole;
        notifyListeners();
      }
    } catch (e) {
      throw Exception('Rol değiştirilemedi: $e');
    }
  }

  Future<void> deleteUser(String uid, String email) async {
    try {
      await _userService.deleteUser(uid);
      
      // Audit Log
      await _auditService.logAction(
        action: 'DELETE_USER',
        details: 'User $email deleted by admin',
      );

      // Listeyi güncelle
      _users.removeWhere((u) => u['uid'] == uid);
      notifyListeners();
    } catch (e) {
      throw Exception('Kullanıcı silinemedi: $e');
    }
  }

  void searchUsers(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
