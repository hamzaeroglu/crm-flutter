import 'package:flutter/material.dart';
import '../../core/services/user_service.dart';
import '../../core/services/audit_service.dart';

class UserManagementProvider extends ChangeNotifier {
  final UserService _userService = UserService();
  final AuditService _auditService = AuditService();

  List<Map<String, dynamic>> _users = [];
  List<Map<String, dynamic>> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> fetchUsers() async {
    _isLoading = true;
    notifyListeners();
    try {
      _users = await _userService.getAllUsers();
    } catch (e) {
      // Hata yönetimi UI tarafında snackbar ile yapılacak
      rethrow; 
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
}
