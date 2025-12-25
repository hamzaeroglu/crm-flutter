import '../../presentation/providers/auth_provider.dart';

class PermissionHelper {
  // Admin tüm işlemleri yapabilir
  static bool canCreateCustomer(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canUpdateCustomer(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canDeleteCustomer(UserRole role) {
    return role == UserRole.admin;
  }

  static bool canViewCustomers(UserRole role) {
    return true; // Tüm roller görebilir
  }

  static bool canManageNotes(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }

  static bool canManageTags(UserRole role) {
    return role == UserRole.admin || role == UserRole.agent;
  }
}

